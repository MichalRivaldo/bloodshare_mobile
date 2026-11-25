'use strict';

const bcrypt = require('bcrypt');
const jwt    = require('jsonwebtoken');
const { validationResult } = require('express-validator');

const userModel    = require('../models/userModel');
const { sendSuccess, sendError } = require('../utils/response');

/** Buat JWT untuk user. */
function signToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
}

/** Hapus password_hash dari objek user sebelum dikembalikan ke client. */
function sanitizeUser(user) {
  const { password_hash, ...safe } = user;
  return safe;
}

// ─── register ────────────────────────────────────────────────────────────────

async function register(req, res, next) {
  try {
    // 1. Validasi input
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        success: false,
        message: 'Validasi gagal.',
        data: errors.array(),
      });
    }

    const {
      nama_lengkap,
      email,
      password,
      no_telepon,
      golongan_darah,
      rhesus,
      kota,
      alamat,
      tanggal_lahir,
      jenis_kelamin,
    } = req.body;

    // 2. Cek email unik
    const existing = await userModel.findByEmail(email);
    if (existing) {
      return sendError(res, { statusCode: 409, message: 'Email sudah terdaftar.' });
    }

    // 3. Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // 4. Insert user baru
    const insertId = await userModel.create({
      nama_lengkap,
      email,
      password_hash,
      no_telepon,
      golongan_darah,
      rhesus,
      kota,
      alamat:        alamat        || null,
      tanggal_lahir: tanggal_lahir || null,
      jenis_kelamin: jenis_kelamin || null,
    });

    // 5. Ambil user yang baru dibuat
    const newUser = await userModel.findById(insertId);
    const token   = signToken(newUser);

    return sendSuccess(res, {
      statusCode: 201,
      message: 'Registrasi berhasil.',
      data: { user: sanitizeUser(newUser), token },
    });
  } catch (err) {
    return next(err);
  }
}

// ─── login ───────────────────────────────────────────────────────────────────

async function login(req, res, next) {
  try {
    // 1. Validasi input
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        success: false,
        message: 'Validasi gagal.',
        data: errors.array(),
      });
    }

    const { email, password } = req.body;

    // 2. Cari user
    const user = await userModel.findByEmail(email);
    if (!user) {
      return sendError(res, { statusCode: 401, message: 'Email atau password salah.' });
    }

    // 3. Bandingkan password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return sendError(res, { statusCode: 401, message: 'Email atau password salah.' });
    }

    // 4. Buat token & kirim response
    const token = signToken(user);

    return sendSuccess(res, {
      message: 'Login berhasil.',
      data: { user: sanitizeUser(user), token },
    });
  } catch (err) {
    return next(err);
  }
}

// ─── getMe ───────────────────────────────────────────────────────────────────

async function getMe(req, res, next) {
  try {
    const user = await userModel.findById(req.user.id);
    if (!user) {
      return sendError(res, { statusCode: 404, message: 'User tidak ditemukan.' });
    }

    return sendSuccess(res, {
      message: 'Data user berhasil diambil.',
      data: { user: sanitizeUser(user) },
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { register, login, getMe };
