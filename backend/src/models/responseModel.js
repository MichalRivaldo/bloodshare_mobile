'use strict';

const { pool } = require('../config/db');

/** Cek apakah donor sudah pernah merespon request ini. */
async function findByRequestAndDonor(requestId, donorId) {
  const [[row]] = await pool.query(
    `SELECT * FROM request_responses WHERE request_id = ? AND donor_id = ?`,
    [requestId, donorId]
  );
  return row || null;
}

/** Ambil satu response by id (beserta data request & donor). */
async function findById(id) {
  const [[row]] = await pool.query(
    `SELECT
       rr.*,
       br.requester_id,
       br.golongan_darah AS req_golongan_darah,
       br.status         AS req_status,
       u.nama_lengkap    AS donor_nama,
       u.no_telepon      AS donor_telepon
     FROM request_responses rr
     JOIN blood_requests br ON br.id = rr.request_id
     JOIN users u           ON u.id  = rr.donor_id
     WHERE rr.id = ?`,
    [id]
  );
  return row || null;
}

/** Buat response baru. */
async function create(requestId, donorId, pesan) {
  const [result] = await pool.query(
    `INSERT INTO request_responses (request_id, donor_id, pesan) VALUES (?, ?, ?)`,
    [requestId, donorId, pesan || null]
  );
  return result.insertId;
}

/** Update status response (pemilik permintaan). */
async function updateStatus(id, status) {
  const [result] = await pool.query(
    `UPDATE request_responses SET status = ?, updated_at = NOW() WHERE id = ?`,
    [status, id]
  );
  return result.affectedRows;
}

module.exports = { findByRequestAndDonor, findById, create, updateStatus };
