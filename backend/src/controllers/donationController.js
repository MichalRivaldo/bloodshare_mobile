'use strict';

const donationModel = require('../models/donationModel');
const { sendSuccess } = require('../utils/response');

/** GET /api/donations/history */
async function getHistory(req, res, next) {
  try {
    const userId = req.user.id;
    const page   = parseInt(req.query.page, 10)  || 1;
    const limit  = parseInt(req.query.limit, 10) || 10;

    const { history, total } = await donationModel.findHistoryByUser(userId, page, limit);

    return sendSuccess(res, {
      message: 'Riwayat donasi.',
      data: {
        history,
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

/** GET /api/donations/eligibility */
async function getEligibility(req, res, next) {
  try {
    const eligibility = await donationModel.checkEligibility(req.user.id);
    return sendSuccess(res, { message: 'Status kelayakan donor.', data: eligibility });
  } catch (err) {
    next(err);
  }
}

module.exports = { getHistory, getEligibility };
