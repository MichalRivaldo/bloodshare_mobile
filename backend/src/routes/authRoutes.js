'use strict';

const { Router } = require('express');
const { body }   = require('express-validator');

const verifyToken    = require('../middleware/verifyToken');
const authController = require('../controllers/authController');

const router = Router();

// ─── Validation rules ────────────────────────────────────────────────────────

const registerValidation = [
  body('nama_lengkap').notEmpty().withMessage('Nama lengkap wajib diisi.'),
  body('email').isEmail().normalizeEmail().withMessage('Format email tidak valid.'),
  body('password').isLength({ min: 6 }).withMessage('Password minimal 6 karakter.'),
  body('no_telepon').notEmpty().withMessage('Nomor telepon wajib diisi.'),
  body('golongan_darah').isIn(['A', 'B', 'AB', 'O']).withMessage('Golongan darah tidak valid. Pilih A, B, AB, atau O.'),
  body('rhesus').isIn(['+', '-']).withMessage('Rhesus tidak valid. Pilih + atau -.'),
  body('kota').notEmpty().withMessage('Kota wajib diisi.'),
];

const loginValidation = [
  body('email').isEmail().withMessage('Format email tidak valid.'),
  body('password').notEmpty().withMessage('Password wajib diisi.'),
];

// ─── Routes ──────────────────────────────────────────────────────────────────

// POST /api/auth/register
router.post('/register', registerValidation, authController.register);

// POST /api/auth/login
router.post('/login', loginValidation, authController.login);

// GET /api/auth/me
router.get('/me', verifyToken, authController.getMe);

module.exports = router;
