'use strict';

const notificationModel = require('../models/notificationModel');
const { sendSuccess, sendError } = require('../utils/response');

// GET /api/notifications
async function getNotifications(req, res, next) {
  try {
    const { page, limit } = req.query;
    const result = await notificationModel.findByUser(req.user.id, page || 1, limit || 20);
    return sendSuccess(res, {
      message: 'Daftar notifikasi.',
      data: {
        notifications: result.rows,
        pagination: {
          total:       result.total,
          page:        Number(page || 1),
          limit:       Number(limit || 20),
          total_pages: Math.ceil(result.total / Number(limit || 20)),
        },
      },
    });
  } catch (err) { next(err); }
}

// PATCH /api/notifications/:id/read
async function markRead(req, res, next) {
  try {
    const affected = await notificationModel.markRead(req.params.id, req.user.id);
    if (!affected) return sendError(res, { statusCode: 404, message: 'Notifikasi tidak ditemukan.' });
    return sendSuccess(res, { message: 'Notifikasi ditandai sudah dibaca.', data: null });
  } catch (err) { next(err); }
}

module.exports = { getNotifications, markRead };
