'use strict';

const { validationResult } = require('express-validator');

const userModel = require('../models/userModel');
const { sendSuccess, sendError } = require('../utils/response');

/** Hapus password_hash dari objek user. */
function sanitizeUser(user) {
  const { password_hash, ...safe } = user;
  return safe;
}

// ─── updateProfile ───────────────────────────────────────────────────────────

async function updateProfile(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        success: false,
        message: 'Validasi gagal.',
        data: errors.array(),
      });
    }

    const id = req.user.id;
    const {
      nama_lengkap,
      no_telepon,
      kota,
      alamat,
      tanggal_lahir,
      jenis_kelamin,
      golongan_darah,
      rhesus,
    } = req.body;

    await userModel.updateProfile(id, {
      nama_lengkap,
      no_telepon,
      kota,
      alamat,
      tanggal_lahir,
      jenis_kelamin,
      golongan_darah,
      rhesus,
    });

    const updated = await userModel.findById(id);

    return sendSuccess(res, {
      message: 'Profil berhasil diperbarui.',
      data: { user: sanitizeUser(updated) },
    });
  } catch (err) {
    return next(err);
  }
}

// ─── toggleAvailability ──────────────────────────────────────────────────────

async function toggleAvailability(req, res, next) {
  try {
    const id   = req.user.id;
    const user = await userModel.findById(id);

    if (!user) {
      return sendError(res, { statusCode: 404, message: 'User tidak ditemukan.' });
    }

    const newStatus = user.is_donor_aktif ? 0 : 1;
    await userModel.updateDonorStatus(id, newStatus);

    return sendSuccess(res, {
      message: newStatus
        ? 'Kamu sekarang terdaftar sebagai donor aktif.'
        : 'Kamu sekarang tidak aktif sebagai donor.',
      data: { is_donor_aktif: Boolean(newStatus) },
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { updateProfile, toggleAvailability };
