'use strict';

const mysql = require('mysql2/promise');

/**
 * Connection pool ke MySQL XAMPP.
 * Variabel diambil dari .env via dotenv (di-load di app.js).
 */
const pool = mysql.createPool({
  host:               process.env.DB_HOST     || 'localhost',
  port:               parseInt(process.env.DB_PORT || '3306', 10),
  user:               process.env.DB_USER     || 'root',
  password:           process.env.DB_PASS     || '',
  database:           process.env.DB_NAME     || 'bloodshare',
  waitForConnections: true,
  connectionLimit:    10,
  queueLimit:         0,
  charset:            'utf8mb4',
});

/**
 * Uji koneksi ke database.
 * @returns {Promise<{ ok: boolean, message: string }>}
 */
async function testConnection() {
  try {
    const conn = await pool.getConnection();
    conn.release();
    return { ok: true, message: 'Koneksi database berhasil.' };
  } catch (err) {
    return { ok: false, message: `Koneksi database gagal: ${err.message}` };
  }
}

module.exports = { pool, testConnection };

