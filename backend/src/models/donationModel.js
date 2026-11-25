'use strict';

const { pool } = require('../config/db');

const MIN_DAYS = 56;

/**
 * Riwayat donasi user, urutkan terbaru.
 * @param {number} userId
 * @param {number} page
 * @param {number} limit
 */
async function findHistoryByUser(userId, page = 1, limit = 10) {
  const offset = (page - 1) * limit;

  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total FROM donation_history WHERE donor_id = ?`,
    [userId],
  );
  const total = countRows[0].total;

  const [rows] = await pool.query(
    `SELECT * FROM donation_history WHERE donor_id = ? ORDER BY tanggal_donor DESC LIMIT ? OFFSET ?`,
    [userId, Number(limit), Number(offset)],
  );

  return { history: rows, total };
}

/**
 * Cek kelayakan donor berdasarkan last_donor_at.
 * Jeda minimal 56 hari.
 * @param {number} userId
 * @returns {{ isEligible: boolean, lastDonorAt: string|null, nextEligibleAt: string|null, daysRemaining: number }}
 */
async function checkEligibility(userId) {
  const [rows] = await pool.query(
    `SELECT last_donor_at FROM users WHERE id = ?`,
    [userId],
  );

  if (!rows.length) {
    return { isEligible: false, lastDonorAt: null, nextEligibleAt: null, daysRemaining: 0 };
  }

  const lastDonorAt = rows[0].last_donor_at; // DATE or null

  if (!lastDonorAt) {
    return { isEligible: true, lastDonorAt: null, nextEligibleAt: null, daysRemaining: 0 };
  }

  const last       = new Date(lastDonorAt);
  const nextDate   = new Date(last);
  nextDate.setDate(nextDate.getDate() + MIN_DAYS);

  const now            = new Date();
  const msRemaining    = nextDate - now;
  const daysRemaining  = msRemaining > 0 ? Math.ceil(msRemaining / (1000 * 60 * 60 * 24)) : 0;
  const isEligible     = msRemaining <= 0;

  const toISODate = (d) => d.toISOString().slice(0, 10);

  return {
    isEligible,
    lastDonorAt:    toISODate(last),
    nextEligibleAt: toISODate(nextDate),
    daysRemaining,
  };
}

module.exports = { findHistoryByUser, checkEligibility };
