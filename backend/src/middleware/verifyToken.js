'use strict';

const jwt = require('jsonwebtoken');

/**
 * Middleware: verifikasi JWT dari header Authorization: Bearer <token>.
 * Menyimpan payload ke req.user.
 * Jika tidak ada / invalid / expired → 401.
 */
function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Token tidak ditemukan. Harap login terlebih dahulu.',
      data: null,
    });
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload;
    return next();
  } catch (err) {
    const message =
      err.name === 'TokenExpiredError'
        ? 'Token sudah kadaluarsa. Harap login kembali.'
        : 'Token tidak valid.';

    return res.status(401).json({
      success: false,
      message,
      data: null,
    });
  }
}

module.exports = verifyToken;
