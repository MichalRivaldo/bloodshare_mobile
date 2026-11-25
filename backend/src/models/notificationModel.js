'use strict';

const { pool } = require('../config/db');

/** Buat notifikasi baru. */
async function create(conn, { userId, judul, pesan, tipe, refId = null, refTipe = null }) {
  const [result] = await conn.query(
    `INSERT INTO notifications (user_id, judul, pesan, tipe, ref_id, ref_tipe)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [userId, judul, pesan, tipe, refId, refTipe]
  );
  return result.insertId;
}

/** Ambil semua notifikasi milik user, terbaru dulu. */
async function findByUser(userId, page = 1, limit = 20) {
  const offset = (Number(page) - 1) * Number(limit);
  const [rows] = await pool.query(
    `SELECT * FROM notifications WHERE user_id = ?
     ORDER BY created_at DESC LIMIT ? OFFSET ?`,
    [userId, Number(limit), offset]
  );
  const [[{ total }]] = await pool.query(
    `SELECT COUNT(*) AS total FROM notifications WHERE user_id = ?`,
    [userId]
  );
  return { rows, total: Number(total) };
}

/** Tandai notifikasi sebagai sudah dibaca. */
async function markRead(id, userId) {
  const [result] = await pool.query(
    `UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?`,
    [id, userId]
  );
  return result.affectedRows;
}

module.exports = { create, findByUser, markRead };
