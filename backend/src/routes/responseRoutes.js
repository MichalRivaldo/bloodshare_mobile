'use strict';

const { Router } = require('express');
const { body }   = require('express-validator');
const verifyToken = require('../middleware/verifyToken');
const { respondToRequest, updateResponse } = require('../controllers/responseController');

const router = Router();

// POST /api/requests/:id/respond
router.post('/:id/respond', verifyToken, [
  body('pesan').optional().isString().withMessage('Pesan harus berupa teks.'),
], respondToRequest);

module.exports = router;

// ─── Route untuk PATCH /api/responses/:id ────────────────────────────────────
// (di-mount terpisah di app.js)
const responseRouter = Router();

responseRouter.patch('/:id', verifyToken, [
  body('status')
    .isIn(['dikonfirmasi', 'dibatalkan', 'selesai'])
    .withMessage('Status tidak valid. Pilihan: dikonfirmasi, dibatalkan, selesai.'),
], updateResponse);

module.exports.responseRouter = responseRouter;
