'use strict';

const { pool } = require('../config/db');

/**
 * Cari user berdasarkan email.
 * @param {string} email
 * @returns {Promise<object|null>}
 */
async function findByEmail(email) {
  const [rows] = await pool.query(
    'SELECT * FROM users WHERE email = ? LIMIT 1',
    [email]
  );
  return rows[0] || null;
}

/**
 * Cari user berdasarkan ID.
 * @param {number} id
 * @returns {Promise<object|null>}
 */
async function findById(id) {
  const [rows] = await pool.query(
    'SELECT * FROM users WHERE id = ? LIMIT 1',
    [id]
  );
  return rows[0] || null;
}

/**
 * Buat user baru.
 * @param {object} data - Field user (tanpa id, created_at, updated_at)
 * @returns {Promise<number>} insertId
 */
async function create(data) {
  const {
    nama_lengkap,
    email,
    password_hash,
    no_telepon,
    golongan_darah,
    rhesus,
    kota,
    alamat           = null,
    tanggal_lahir    = null,
    jenis_kelamin    = null,
    is_donor_aktif   = 0,
    role             = 'user',
  } = data;

  const [result] = await pool.query(
    `INSERT INTO users
       (nama_lengkap, email, password_hash, no_telepon, golongan_darah, rhesus,
        kota, alamat, tanggal_lahir, jenis_kelamin, is_donor_aktif, role)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      nama_lengkap, email, password_hash, no_telepon, golongan_darah, rhesus,
      kota, alamat, tanggal_lahir, jenis_kelamin, is_donor_aktif, role,
    ]
  );
  return result.insertId;
}

/**
 * Update profil user.
 * @param {number} id
 * @param {object} data
 * @returns {Promise<void>}
 */
async function updateProfile(id, data) {
  const {
    nama_lengkap,
    no_telepon,
    kota,
    alamat,
    tanggal_lahir,
    jenis_kelamin,
    golongan_darah,
    rhesus,
  } = data;

  await pool.query(
    `UPDATE users SET
       nama_lengkap   = COALESCE(?, nama_lengkap),
       no_telepon     = COALESCE(?, no_telepon),
       kota           = COALESCE(?, kota),
       alamat         = COALESCE(?, alamat),
       tanggal_lahir  = COALESCE(?, tanggal_lahir),
       jenis_kelamin  = COALESCE(?, jenis_kelamin),
       golongan_darah = COALESCE(?, golongan_darah),
       rhesus         = COALESCE(?, rhesus)
     WHERE id = ?`,
    [
      nama_lengkap  ?? null,
      no_telepon    ?? null,
      kota          ?? null,
      alamat        ?? null,
      tanggal_lahir ?? null,
      jenis_kelamin ?? null,
      golongan_darah ?? null,
      rhesus        ?? null,
      id,
    ]
  );
}

/**
 * Update status donor aktif.
 * @param {number} id
 * @param {0|1}   is_donor_aktif
 * @returns {Promise<void>}
 */
async function updateDonorStatus(id, is_donor_aktif) {
  await pool.query(
    'UPDATE users SET is_donor_aktif = ? WHERE id = ?',
    [is_donor_aktif, id]
  );
}

module.exports = { findByEmail, findById, create, updateProfile, updateDonorStatus };
