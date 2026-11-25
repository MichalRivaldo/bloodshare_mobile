'use strict';

const { validationResult } = require('express-validator');
const bloodRequestModel    = require('../models/bloodRequestModel');
const { sendSuccess, sendError } = require('../utils/response');

// ─── POST /api/requests ───────────────────────────────────────────────────────
async function createRequest(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ success: false, message: 'Validasi gagal.', data: errors.array() });
    }

    const insertId = await bloodRequestModel.create({
      requester_id: req.user.id,
      ...req.body,
    });

    const created = await bloodRequestModel.findById(insertId);

    return sendSuccess(res, {
      statusCode: 201,
      message: 'Permintaan darah berhasil dibuat.',
      data: { request: created },
    });
  } catch (err) { next(err); }
}

// ─── GET /api/requests ────────────────────────────────────────────────────────
async function getRequests(req, res, next) {
  try {
    const { golongan_darah, rhesus, kota, urgensi, status, page, limit } = req.query;
    const result = await bloodRequestModel.findAll({
      golongan_darah, rhesus, kota, urgensi, status,
      page:  page  || 1,
      limit: limit || 10,
    });

    return sendSuccess(res, {
      message: 'Daftar permintaan darah.',
      data: {
        requests:   result.rows,
        pagination: {
          total:       result.total,
          page:        result.page,
          limit:       result.limit,
          total_pages: Math.ceil(result.total / result.limit),
        },
      },
    });
  } catch (err) { next(err); }
}

// ─── GET /api/requests/:id ────────────────────────────────────────────────────
async function getRequestById(req, res, next) {
  try {
    const request = await bloodRequestModel.findById(req.params.id);
    if (!request) {
      return sendError(res, { statusCode: 404, message: 'Permintaan tidak ditemukan.' });
    }
    return sendSuccess(res, { message: 'Detail permintaan darah.', data: { request } });
  } catch (err) { next(err); }
}

// ─── PUT /api/requests/:id ────────────────────────────────────────────────────
async function updateRequest(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ success: false, message: 'Validasi gagal.', data: errors.array() });
    }

    // Cek request ada & milik user
    const existing = await bloodRequestModel.findById(req.params.id);
    if (!existing) return sendError(res, { statusCode: 404, message: 'Permintaan tidak ditemukan.' });
    if (existing.requester_id !== req.user.id) {
      return sendError(res, { statusCode: 403, message: 'Anda tidak berhak mengubah permintaan ini.' });
    }

    const affected = await bloodRequestModel.update(req.params.id, req.user.id, req.body);
    if (!affected) return sendError(res, { statusCode: 400, message: 'Gagal mengupdate permintaan.' });

    const updated = await bloodRequestModel.findById(req.params.id);
    return sendSuccess(res, { message: 'Permintaan berhasil diupdate.', data: { request: updated } });
  } catch (err) { next(err); }
}

// ─── PATCH /api/requests/:id/status ──────────────────────────────────────────
async function updateRequestStatus(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ success: false, message: 'Validasi gagal.', data: errors.array() });
    }

    const existing = await bloodRequestModel.findById(req.params.id);
    if (!existing) return sendError(res, { statusCode: 404, message: 'Permintaan tidak ditemukan.' });
    if (existing.requester_id !== req.user.id) {
      return sendError(res, { statusCode: 403, message: 'Anda tidak berhak mengubah status ini.' });
    }

    await bloodRequestModel.updateStatus(req.params.id, req.user.id, req.body.status);
    const updated = await bloodRequestModel.findById(req.params.id);
    return sendSuccess(res, { message: 'Status permintaan diperbarui.', data: { request: updated } });
  } catch (err) { next(err); }
}

module.exports = { createRequest, getRequests, getRequestById, updateRequest, updateRequestStatus };
