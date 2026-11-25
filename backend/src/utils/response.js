'use strict';

/**
 * Helper: kirim respons sukses dengan format konsisten.
 *
 * @param {import('express').Response} res
 * @param {object} options
 * @param {number}  [options.statusCode=200]
 * @param {string}  [options.message='Berhasil.']
 * @param {*}       [options.data=null]
 */
function sendSuccess(res, { statusCode = 200, message = 'Berhasil.', data = null } = {}) {
  return res.status(statusCode).json({ success: true, message, data });
}

/**
 * Helper: kirim respons error dengan format konsisten.
 *
 * @param {import('express').Response} res
 * @param {object} options
 * @param {number}  [options.statusCode=500]
 * @param {string}  [options.message='Terjadi kesalahan.']
 * @param {*}       [options.data=null]
 */
function sendError(res, { statusCode = 500, message = 'Terjadi kesalahan.', data = null } = {}) {
  return res.status(statusCode).json({ success: false, message, data });
}

/**
 * Buat objek Error dengan properti statusCode.
 *
 * @param {string} message
 * @param {number} statusCode
 * @returns {Error}
 */
function createError(message, statusCode = 500) {
  const err = new Error(message);
  err.statusCode = statusCode;
  return err;
}

module.exports = { sendSuccess, sendError, createError };

