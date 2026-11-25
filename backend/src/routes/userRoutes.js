'use strict';

const { Router } = require('express');
const { body }   = require('express-validator');

const verifyToken    = require('../middleware/verifyToken');
const userController = require('../controllers/userController');

const router = Router();

// ─── Validation rules ────────────────────────────────────────────────────────

const updateProfileValidation = [
  body('nama_lengkap').optional().notEmpty().withMessage('Nama lengkap tidak boleh kosong.'),
  body('no_telepon').optional().notEmpty().withMessage('Nomor telepon tidak boleh kosong.'),
  body('kota').optional().notEmpty().withMessage('Kota tidak boleh kosong.'),
  body('jenis_kelamin').optional().isIn(['L', 'P']).withMessage('Jenis kelamin tidak valid. Pilih L atau P.'),
  body('golongan_darah').optional().isIn(['A', 'B', 'AB', 'O']).withMessage('Golongan darah tidak valid.'),
  body('rhesus').optional().isIn(['+', '-']).withMessage('Rhesus tidak valid. Pilih + atau -.'),
  body('tanggal_lahir').optional().isDate().withMessage('Format tanggal lahir tidak valid (YYYY-MM-DD).'),
];

// ─── Routes ──────────────────────────────────────────────────────────────────

// PUT /api/users/profile
router.put('/profile', verifyToken, updateProfileValidation, userController.updateProfile);

// PATCH /api/users/availability
router.patch('/availability', verifyToken, userController.toggleAvailability);

module.exports = router;
