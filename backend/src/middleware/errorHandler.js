'use strict';

/**
 * Global error handler middleware.
 * Harus didaftarkan sebagai middleware TERAKHIR di app.js.
 *
 * Format respons error konsisten:
 * { success: false, message: string, data: null }
 */
function errorHandler(err, req, res, next) { // eslint-disable-line no-unused-vars
  // Log error di server (sembunyikan stack di production)
  if (process.env.NODE_ENV !== 'production') {
    console.error('[ERROR]', err);
  } else {
    console.error('[ERROR]', err.message);
  }

  // Tentukan HTTP status code
  const statusCode = err.statusCode || err.status || 500;

  return res.status(statusCode).json({
    success: false,
    message: err.message || 'Terjadi kesalahan pada server.',
    data:    null,
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
  });
}

/**
 * 404 Not Found handler.
 * Daftarkan sebelum errorHandler, setelah semua route.
 */
function notFoundHandler(req, res) {
  return res.status(404).json({
    success: false,
    message: `Endpoint tidak ditemukan: ${req.method} ${req.originalUrl}`,
    data:    null,
  });
}

module.exports = { errorHandler, notFoundHandler };

