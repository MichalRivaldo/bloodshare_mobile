'use strict';

const { Router } = require('express');
const { body, query } = require('express-validator');
const verifyToken = require('../middleware/verifyToken');
const {
  createRequest, getRequests, getRequestById,
  updateRequest, updateRequestStatus,
} = require('../controllers/bloodRequestController');

const router = Router();

const requestBodyRules = [
  body('golongan_darah').isIn(['A','B','AB','O']).withMessage('Golongan darah tidak valid.'),
  body('rhesus').isIn(['+','-']).withMessage('Rhesus tidak valid.'),
  body('nama_pasien').notEmpty().withMessage('Nama pasien wajib diisi.'),
  body('nama_rs').notEmpty().withMessage('Nama rumah sakit wajib diisi.'),
  body('kota').notEmpty().withMessage('Kota wajib diisi.'),
  body('tanggal_dibutuhkan').isDate().withMessage('Tanggal dibutuhkan tidak valid (format: YYYY-MM-DD).'),
  body('urgensi').isIn(['darurat','segera','terjadwal']).withMessage('Urgensi tidak valid.'),
  body('jumlah_kantong').optional().isInt({ min: 1 }).withMessage('Jumlah kantong minimal 1.'),
];

// POST /api/requests
router.post('/', verifyToken, requestBodyRules, createRequest);

// GET /api/requests
router.get('/', getRequests);

// GET /api/requests/:id
router.get('/:id', getRequestById);

// PUT /api/requests/:id
router.put('/:id', verifyToken, requestBodyRules, updateRequest);

// PATCH /api/requests/:id/status
router.patch('/:id/status', verifyToken, [
  body('status')
    .isIn(['aktif','terpenuhi','dibatalkan'])
    .withMessage('Status tidak valid. Pilihan: aktif, terpenuhi, dibatalkan.'),
], updateRequestStatus);

module.exports = router;
