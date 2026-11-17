'use strict';

const { testConnection } = require('../config/db');

/**
 * GET /api/health
 * Mengecek status server dan koneksi database.
 */
async function healthCheck(req, res, next) {
  try {
    const db = await testConnection();

    return res.status(db.ok ? 200 : 503).json({
      success: db.ok,
      message: db.ok ? 'Server dan database berjalan normal.' : 'Server aktif, tetapi database tidak dapat diakses.',
      data: {
        server:    'OK',
        database:  db.ok ? 'OK' : 'ERROR',
        dbMessage: db.message,
        timestamp: new Date().toISOString(),
        env:       process.env.NODE_ENV || 'development',
      },
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { healthCheck };
