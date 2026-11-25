'use strict';

const { validationResult } = require('express-validator');
const eventModel = require('../models/eventModel');
const { sendSuccess, sendError, createError } = require('../utils/response');

/** GET /api/events */
async function getEvents(req, res, next) {
  try {
    const { kota, status } = req.query;
    const page  = parseInt(req.query.page, 10)  || 1;
    const limit = parseInt(req.query.limit, 10) || 10;

    const { events, total } = await eventModel.findAll({ kota, status, page, limit });

    return sendSuccess(res, {
      message: 'Daftar event donor darah.',
      data: {
        events,
        pagination: {
          total,
          page,
          limit,
          total_pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (err) {
    next(err);
  }
}

/** POST /api/events */
async function createEvent(req, res, next) {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, { statusCode: 422, message: 'Validasi gagal.', data: errors.array() });
    }

    const { judul, deskripsi, nama_lokasi, kota, alamat, tanggal_mulai, tanggal_selesai, kuota } = req.body;

    const id = await eventModel.create({
      organizer_id: req.user.id,
      judul, deskripsi, nama_lokasi, kota, alamat,
      tanggal_mulai, tanggal_selesai, kuota,
    });

    const event = await eventModel.findById(id);
    return sendSuccess(res, { statusCode: 201, message: 'Event berhasil dibuat.', data: { event } });
  } catch (err) {
    next(err);
  }
}

/** GET /api/events/:id */
async function getEventById(req, res, next) {
  try {
    const event = await eventModel.findById(req.params.id);
    if (!event) {
      return sendError(res, { statusCode: 404, message: 'Event tidak ditemukan.', data: null });
    }
    return sendSuccess(res, { message: 'Detail event.', data: { event } });
  } catch (err) {
    next(err);
  }
}

/** POST /api/events/:id/join */
async function joinEvent(req, res, next) {
  try {
    const eventId = Number(req.params.id);
    const userId  = req.user.id;

    const event = await eventModel.findById(eventId);
    if (!event) {
      return sendError(res, { statusCode: 404, message: 'Event tidak ditemukan.', data: null });
    }
    if (event.status !== 'akan_datang') {
      return sendError(res, { statusCode: 400, message: 'Event tidak lagi menerima peserta.', data: null });
    }

    const existing = await eventModel.findParticipant(eventId, userId);
    if (existing) {
      return sendError(res, { statusCode: 409, message: 'Kamu sudah terdaftar di event ini.', data: null });
    }

    const participants = await eventModel.countParticipants(eventId);
    if (participants >= event.kuota) {
      return sendError(res, { statusCode: 400, message: 'Kuota event sudah penuh.', data: null });
    }

    await eventModel.addParticipant(eventId, userId);
    return sendSuccess(res, { statusCode: 201, message: 'Berhasil mendaftar ke event.', data: null });
  } catch (err) {
    next(err);
  }
}

/** DELETE /api/events/:id/join */
async function leaveEvent(req, res, next) {
  try {
    const eventId = Number(req.params.id);
    const userId  = req.user.id;

    const existing = await eventModel.findParticipant(eventId, userId);
    if (!existing) {
      return sendError(res, { statusCode: 404, message: 'Kamu tidak terdaftar di event ini.', data: null });
    }

    await eventModel.removeParticipant(eventId, userId);
    return sendSuccess(res, { message: 'Berhasil keluar dari event.', data: null });
  } catch (err) {
    next(err);
  }
}

module.exports = { getEvents, createEvent, getEventById, joinEvent, leaveEvent };
