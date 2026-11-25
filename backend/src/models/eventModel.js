'use strict';

const { pool } = require('../config/db');

/**
 * List events dengan filter dan pagination.
 * @param {{ kota?: string, status?: string, page?: number, limit?: number }} opts
 */
async function findAll({ kota, status, page = 1, limit = 10 } = {}) {
  const offset = (page - 1) * limit;
  const conditions = [];
  const values = [];

  if (kota) {
    conditions.push('kota = ?');
    values.push(kota);
  }
  if (status) {
    conditions.push('status = ?');
    values.push(status);
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

  const countSql = `SELECT COUNT(*) AS total FROM donor_events ${where}`;
  const dataSql  = `SELECT * FROM donor_events ${where} ORDER BY tanggal_mulai ASC LIMIT ? OFFSET ?`;

  const [countRows] = await pool.query(countSql, values);
  const total = countRows[0].total;

  const [rows] = await pool.query(dataSql, [...values, Number(limit), Number(offset)]);

  return { events: rows, total };
}

/**
 * Detail event + jumlah peserta aktif.
 * @param {number} id
 */
async function findById(id) {
  const sql = `
    SELECT e.*,
           (SELECT COUNT(*) FROM event_participants WHERE event_id = e.id AND status != 'dibatalkan') AS jumlah_peserta
    FROM donor_events e
    WHERE e.id = ?
  `;
  const [rows] = await pool.query(sql, [id]);
  return rows[0] || null;
}

/**
 * Buat event baru.
 * @param {object} data
 */
async function create(data) {
  const {
    organizer_id, judul, deskripsi = null,
    nama_lokasi, kota, alamat = null,
    tanggal_mulai, tanggal_selesai, kuota,
    status = 'akan_datang',
  } = data;

  const sql = `
    INSERT INTO donor_events (organizer_id, judul, deskripsi, nama_lokasi, kota, alamat,
                              tanggal_mulai, tanggal_selesai, kuota, status)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;
  const [result] = await pool.query(sql, [
    organizer_id, judul, deskripsi, nama_lokasi, kota, alamat,
    tanggal_mulai, tanggal_selesai, kuota, status,
  ]);
  return result.insertId;
}

/**
 * Hitung peserta aktif (status != 'dibatalkan').
 * @param {number} eventId
 */
async function countParticipants(eventId) {
  const [rows] = await pool.query(
    `SELECT COUNT(*) AS total FROM event_participants WHERE event_id = ? AND status != 'dibatalkan'`,
    [eventId],
  );
  return rows[0].total;
}

/**
 * Cek apakah user sudah join event (status != 'dibatalkan').
 * @param {number} eventId
 * @param {number} userId
 */
async function findParticipant(eventId, userId) {
  const [rows] = await pool.query(
    `SELECT * FROM event_participants WHERE event_id = ? AND user_id = ? AND status != 'dibatalkan'`,
    [eventId, userId],
  );
  return rows[0] || null;
}

/**
 * Tambah peserta ke event.
 * @param {number} eventId
 * @param {number} userId
 */
async function addParticipant(eventId, userId) {
  const [result] = await pool.query(
    `INSERT INTO event_participants (event_id, user_id, status) VALUES (?, ?, 'terdaftar')`,
    [eventId, userId],
  );
  return result.insertId;
}

/**
 * Batalkan keikutsertaan user (update status -> 'dibatalkan').
 * @param {number} eventId
 * @param {number} userId
 */
async function removeParticipant(eventId, userId) {
  await pool.query(
    `UPDATE event_participants SET status = 'dibatalkan' WHERE event_id = ? AND user_id = ?`,
    [eventId, userId],
  );
}

module.exports = { findAll, findById, create, countParticipants, findParticipant, addParticipant, removeParticipant };
