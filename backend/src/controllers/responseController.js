'use strict';

const { validationResult } = require('express-validator');
const { pool }             = require('../config/db');
const responseModel        = require('../models/responseModel');
const bloodRequestModel    = require('../models/bloodRequestModel');
const notificationModel    = require('../models/notificationModel');
const userModel            = require('../models/userModel');
const { sendSuccess, sendError } = require('../utils/response');

// ─── POST /api/requests/:id/respond ─────────────────────────────────────────
async function respondToRequest(req, res, next) {
  const conn = await pool.getConnection();
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ success: false, message: 'Validasi gagal.', data: errors.array() });
    }

    const requestId = Number(req.params.id);
    const donorId   = req.user.id;

    // 1. Cek request ada
    const request = await bloodRequestModel.findById(requestId);
    if (!request) return sendError(res, { statusCode: 404, message: 'Permintaan tidak ditemukan.' });

    // 2. Jangan merespon permintaan sendiri
    if (request.requester_id === donorId) {
      return sendError(res, { statusCode: 400, message: 'Anda tidak dapat merespon permintaan sendiri.' });
    }

    // 3. Jangan merespon dua kali
    const already = await responseModel.findByRequestAndDonor(requestId, donorId);
    if (already) {
      return sendError(res, { statusCode: 409, message: 'Anda sudah merespon permintaan ini.' });
    }

    // 4. Cek request masih aktif
    if (request.status !== 'aktif') {
      return sendError(res, { statusCode: 400, message: `Permintaan sudah berstatus "${request.status}".` });
    }

    await conn.beginTransaction();

    // 5. Simpan response
    const responseId = await responseModel.create(requestId, donorId, req.body.pesan);

    // 6. Notifikasi ke pemilik permintaan
    const donor = await userModel.findById(donorId);
    await notificationModel.create(conn, {
      userId:  request.requester_id,
      judul:   'Ada pendonor yang merespon!',
      pesan:   `${donor.nama_lengkap} bersedia membantu permintaan darah ${request.golongan_darah}${request.rhesus} Anda di ${request.nama_rs}.`,
      tipe:    'respons_donor',
      refId:   requestId,
      refTipe: 'blood_request',
    });

    await conn.commit();

    return sendSuccess(res, {
      statusCode: 201,
      message: 'Respon berhasil dikirim. Pemilik permintaan akan segera menghubungi Anda.',
      data: { response_id: responseId },
    });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
}

// ─── PATCH /api/responses/:id ─────────────────────────────────────────────────
async function updateResponse(req, res, next) {
  const conn = await pool.getConnection();
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ success: false, message: 'Validasi gagal.', data: errors.array() });
    }

    const { status } = req.body; // dikonfirmasi | dibatalkan | selesai
    const responseRow = await responseModel.findById(req.params.id);

    if (!responseRow) return sendError(res, { statusCode: 404, message: 'Respon tidak ditemukan.' });

    // Hanya pemilik permintaan yang boleh update
    if (responseRow.requester_id !== req.user.id) {
      return sendError(res, { statusCode: 403, message: 'Hanya pemilik permintaan yang dapat mengubah status respon.' });
    }

    await conn.beginTransaction();

    // Update status response
    await responseModel.updateStatus(req.params.id, status);

    // Notifikasi ke donor
    if (status === 'dikonfirmasi') {
      await notificationModel.create(conn, {
        userId:  responseRow.donor_id,
        judul:   'Respon Anda diterima! 🎉',
        pesan:   `Pemilik permintaan darah ${responseRow.req_golongan_darah} telah menerima kesediaan Anda. Silakan segera ke lokasi.`,
        tipe:    'respons_donor',
        refId:   responseRow.request_id,
        refTipe: 'blood_request',
      });
    } else if (status === 'dibatalkan') {
      await notificationModel.create(conn, {
        userId:  responseRow.donor_id,
        judul:   'Respon Anda ditolak',
        pesan:   `Maaf, pemilik permintaan darah telah membatalkan respon Anda. Terima kasih atas kesediaan Anda.`,
        tipe:    'respons_donor',
        refId:   responseRow.request_id,
        refTipe: 'blood_request',
      });
    } else if (status === 'selesai') {
      // Ambil detail request untuk donation_history
      const [[reqDetail]] = await conn.query(
        `SELECT nama_rs, kota, golongan_darah FROM blood_requests WHERE id = ?`,
        [responseRow.request_id]
      );

      // Catat ke donation_history & update last_donor_at + total_donasi
      await conn.query(
        `INSERT INTO donation_history
           (donor_id, request_id, tanggal_donor, lokasi, kota, golongan_darah, jumlah_kantong)
         VALUES (?, ?, CURDATE(), ?, ?, ?, 1)`,
        [
          responseRow.donor_id,
          responseRow.request_id,
          reqDetail ? reqDetail.nama_rs : null,
          reqDetail ? reqDetail.kota    : null,
          reqDetail ? reqDetail.golongan_darah : responseRow.req_golongan_darah,
        ]
      );

      // Update last_donor_at & total_donasi donor
      await conn.query(
        `UPDATE users
           SET last_donor_at = CURDATE(),
               total_donasi  = total_donasi + 1,
               updated_at    = NOW()
         WHERE id = ?`,
        [responseRow.donor_id]
      );

      // Update status request jadi 'terpenuhi'
      await conn.query(
        `UPDATE blood_requests SET status = 'terpenuhi', updated_at = NOW() WHERE id = ?`,
        [responseRow.request_id]
      );

      // Notifikasi ke donor
      await notificationModel.create(conn, {
        userId:  responseRow.donor_id,
        judul:   'Donasi Anda berhasil dicatat! ❤️',
        pesan:   `Terima kasih! Donasi darah Anda telah dicatat di riwayat. Anda sudah menyelamatkan nyawa.`,
        tipe:    'respons_donor',
        refId:   responseRow.request_id,
        refTipe: 'blood_request',
      });
    }

    await conn.commit();

    return sendSuccess(res, { message: `Status respon diperbarui menjadi "${status}".`, data: null });
  } catch (err) {
    await conn.rollback();
    next(err);
  } finally {
    conn.release();
  }
}

module.exports = { respondToRequest, updateResponse };
