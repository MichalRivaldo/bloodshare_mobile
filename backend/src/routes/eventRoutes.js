'use strict';

const { Router } = require('express');
const { body }   = require('express-validator');

const verifyToken      = require('../middleware/verifyToken');
const eventController  = require('../controllers/eventController');

const router = Router();

// ── Validasi POST /api/events ──────────────────────────────────
const createEventValidation = [
  body('judul').notEmpty().withMessage('Judul wajib diisi.'),
  body('nama_lokasi').notEmpty().withMessage('Nama lokasi wajib diisi.'),
  body('kota').notEmpty().withMessage('Kota wajib diisi.'),
  body('tanggal_mulai').isDate().withMessage('Tanggal mulai harus berupa tanggal valid (YYYY-MM-DD).'),
  body('tanggal_selesai').isDate().withMessage('Tanggal selesai harus berupa tanggal valid (YYYY-MM-DD).'),
  body('kuota').isInt({ min: 1 }).withMessage('Kuota harus berupa angka positif.'),
];

// ── Routes ─────────────────────────────────────────────────────
router.get('/',          eventController.getEvents);
router.post('/',         verifyToken, createEventValidation, eventController.createEvent);
router.get('/:id',       eventController.getEventById);
router.post('/:id/join', verifyToken, eventController.joinEvent);
router.delete('/:id/join', verifyToken, eventController.leaveEvent);

module.exports = router;
