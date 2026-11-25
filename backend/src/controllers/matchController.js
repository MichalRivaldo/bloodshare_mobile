'use strict';

const { pool }                = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');
const { getCompatibleDonors, canDonate } = require('../utils/compatibility');

/**
 * GET /api/requests/:id/matches
 * Temukan donor yang cocok untuk permintaan darah tertentu.
 * Butuh login (verifyToken).
 */
async function getMatches(req, res, next) {
  try {
    const requestId = req.params.id;

    // 1. Ambil data blood_request
    const [requests] = await pool.query(
      'SELECT id, requester_id, golongan_darah, rhesus, kota FROM blood_requests WHERE id = ?',
      [requestId]
    );

    if (!requests.length) {
      return sendError(res, { statusCode: 404, message: 'Permintaan darah tidak ditemukan.' });
    }

    const request = requests[0];
    const { requester_id, golongan_darah, rhesus, kota } = request;

    // 2. Dapatkan daftar golongan donor yang kompatibel
    const compatibleDonors = getCompatibleDonors(golongan_darah, rhesus);

    if (!compatibleDonors.length) {
      return sendSuccess(res, { message: 'Tidak ada donor yang kompatibel.', data: { matches: [] } });
    }

    // Buat daftar golongan_darah unik untuk IN clause
    const compatibleGolongans = [...new Set(compatibleDonors.map((d) => d.golongan))];
    const placeholders = compatibleGolongans.map(() => '?').join(', ');

    // 3. Query donors: aktif, kota sama, eligible (56 hari), bukan requester
    const sql = `
      SELECT
        id, nama_lengkap, email, no_telepon,
        golongan_darah, rhesus, kota,
        is_donor_aktif, last_donor_at, total_donasi
      FROM users
      WHERE is_donor_aktif = 1
        AND golongan_darah IN (${placeholders})
        AND kota = ?
        AND id != ?
        AND (
          last_donor_at IS NULL
          OR last_donor_at <= DATE_SUB(CURDATE(), INTERVAL 56 DAY)
        )
      ORDER BY last_donor_at ASC
    `;

    const queryParams = [...compatibleGolongans, kota, requester_id];
    const [donors] = await pool.query(sql, queryParams);

    if (!donors.length) {
      return sendSuccess(res, {
        message: 'Tidak ada donor tersedia saat ini.',
        data: { matches: [] },
      });
    }

    // 4. Hitung skor
    // last_donor_at paling lama (index 0 setelah ORDER BY ASC) mendapat +1
    // Semua dapat +2 (kota sama sudah difilter)
    const oldestDonorId = donors.length > 0 ? donors[0].id : null;

    const scored = donors.map((donor) => {
      let score = 2; // +2 kota sama (sudah difilter)

      // +3 jika golongan & rhesus tepat sama
      if (canDonate(donor.golongan_darah, donor.rhesus, golongan_darah, rhesus)
          && donor.golongan_darah === golongan_darah
          && donor.rhesus === rhesus) {
        score += 3;
      }

      // +1 jika last_donor_at paling lama (donor pertama dalam ORDER BY ASC)
      if (donor.id === oldestDonorId) {
        score += 1;
      }

      return { ...donor, score };
    });

    // Sort skor tertinggi di atas
    scored.sort((a, b) => b.score - a.score);

    return sendSuccess(res, {
      message: `Ditemukan ${scored.length} donor yang cocok.`,
      data: { matches: scored },
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/stats
 * Statistik publik BloodShare.
 */
async function getStats(req, res, next) {
  try {
    const [[{ total_users }]] = await pool.query('SELECT COUNT(*) AS total_users FROM users');
    const [[{ total_donor_aktif }]] = await pool.query(
      'SELECT COUNT(*) AS total_donor_aktif FROM users WHERE is_donor_aktif = 1'
    );
    const [[{ total_permintaan }]] = await pool.query(
      'SELECT COUNT(*) AS total_permintaan FROM blood_requests'
    );
    const [[{ permintaan_terpenuhi }]] = await pool.query(
      "SELECT COUNT(*) AS permintaan_terpenuhi FROM blood_requests WHERE status = 'terpenuhi'"
    );

    const [distribusiRows] = await pool.query(
      'SELECT golongan_darah, COUNT(*) AS jumlah FROM users GROUP BY golongan_darah'
    );
    const distribusi_golongan = distribusiRows.reduce((acc, row) => {
      acc[row.golongan_darah] = row.jumlah;
      return acc;
    }, {});

    // donation_history mungkin bisa jadi tabel yang belum ada; handle gracefully
    let total_donasi_tercatat = 0;
    try {
      const [[{ cnt }]] = await pool.query(
        'SELECT COUNT(*) AS cnt FROM donation_history'
      );
      total_donasi_tercatat = cnt;
    } catch (_) {
      total_donasi_tercatat = 0;
    }

    return sendSuccess(res, {
      message: 'Statistik BloodShare.',
      data: {
        total_users,
        total_donor_aktif,
        total_permintaan,
        permintaan_terpenuhi,
        distribusi_golongan,
        total_donasi_tercatat,
      },
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { getMatches, getStats };
