'use strict';

const { pool } = require('../config/db');

/**
 * Ambil semua permintaan dengan filter & pagination.
 * Sekaligus auto-expire: UPDATE dulu sebelum SELECT.
 */
async function findAll({ golongan_darah, rhesus, kota, urgensi, status, page = 1, limit = 10 }) {
  const conn = await pool.getConnection();
  try {
    // Auto-expire: ubah status 'aktif' yang tanggal_dibutuhkan-nya sudah lewat
    await conn.query(
      `UPDATE blood_requests
         SET status = 'kadaluarsa', updated_at = NOW()
       WHERE status = 'aktif'
         AND tanggal_dibutuhkan < CURDATE()`
    );

    const conditions = [];
    const params     = [];

    if (golongan_darah) { conditions.push('br.golongan_darah = ?'); params.push(golongan_darah); }
    if (rhesus)         { conditions.push('br.rhesus = ?');         params.push(rhesus); }
    if (kota)           { conditions.push('br.kota LIKE ?');         params.push(`%${kota}%`); }
    if (urgensi)        { conditions.push('br.urgensi = ?');         params.push(urgensi); }
    if (status)         { conditions.push('br.status = ?');          params.push(status); }

    const where  = conditions.length ? 'WHERE ' + conditions.join(' AND ') : '';
    const offset = (Number(page) - 1) * Number(limit);

    const [rows] = await conn.query(
      `SELECT
         br.*,
         u.nama_lengkap  AS requester_nama,
         u.no_telepon    AS requester_telepon,
         (SELECT COUNT(*) FROM request_responses rr WHERE rr.request_id = br.id) AS jumlah_respon
       FROM blood_requests br
       JOIN users u ON u.id = br.requester_id
       ${where}
       ORDER BY
         FIELD(br.urgensi, 'darurat', 'segera', 'terjadwal'),
         br.created_at DESC
       LIMIT ? OFFSET ?`,
      [...params, Number(limit), offset]
    );

    const [[{ total }]] = await conn.query(
      `SELECT COUNT(*) AS total
         FROM blood_requests br
         ${where}`,
      params
    );

    return { rows, total: Number(total), page: Number(page), limit: Number(limit) };
  } finally {
    conn.release();
  }
}

/** Ambil satu permintaan beserta pembuat & jumlah responden. */
async function findById(id) {
  // Auto-expire dulu
  await pool.query(
    `UPDATE blood_requests
       SET status = 'kadaluarsa', updated_at = NOW()
     WHERE id = ? AND status = 'aktif' AND tanggal_dibutuhkan < CURDATE()`,
    [id]
  );

  const [[row]] = await pool.query(
    `SELECT
       br.*,
       u.id            AS requester_id,
       u.nama_lengkap  AS requester_nama,
       u.no_telepon    AS requester_telepon,
       u.kota          AS requester_kota,
       (SELECT COUNT(*) FROM request_responses rr WHERE rr.request_id = br.id) AS jumlah_respon
     FROM blood_requests br
     JOIN users u ON u.id = br.requester_id
     WHERE br.id = ?`,
    [id]
  );
  return row || null;
}

/** Buat permintaan baru. */
async function create(data) {
  const {
    requester_id, golongan_darah, rhesus, jumlah_kantong,
    urgensi, nama_pasien, nama_rs, kota, alamat_rs,
    tanggal_dibutuhkan, keterangan,
  } = data;

  const [result] = await pool.query(
    `INSERT INTO blood_requests
       (requester_id, golongan_darah, rhesus, jumlah_kantong, urgensi,
        nama_pasien, nama_rs, kota, alamat_rs, tanggal_dibutuhkan, keterangan)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [requester_id, golongan_darah, rhesus, jumlah_kantong || 1,
     urgensi, nama_pasien, nama_rs, kota, alamat_rs || null,
     tanggal_dibutuhkan, keterangan || null]
  );
  return result.insertId;
}

/** Update data permintaan (hanya pemilik). */
async function update(id, requesterId, data) {
  const {
    golongan_darah, rhesus, jumlah_kantong, urgensi,
    nama_pasien, nama_rs, kota, alamat_rs,
    tanggal_dibutuhkan, keterangan,
  } = data;

  const [result] = await pool.query(
    `UPDATE blood_requests
       SET golongan_darah = ?, rhesus = ?, jumlah_kantong = ?, urgensi = ?,
           nama_pasien = ?, nama_rs = ?, kota = ?, alamat_rs = ?,
           tanggal_dibutuhkan = ?, keterangan = ?, updated_at = NOW()
     WHERE id = ? AND requester_id = ?`,
    [golongan_darah, rhesus, jumlah_kantong, urgensi,
     nama_pasien, nama_rs, kota, alamat_rs || null,
     tanggal_dibutuhkan, keterangan || null, id, requesterId]
  );
  return result.affectedRows;
}

/** Update hanya status permintaan (hanya pemilik). */
async function updateStatus(id, requesterId, status) {
  const [result] = await pool.query(
    `UPDATE blood_requests
       SET status = ?, updated_at = NOW()
     WHERE id = ? AND requester_id = ?`,
    [status, id, requesterId]
  );
  return result.affectedRows;
}

module.exports = { findAll, findById, create, update, updateStatus };
