'use strict';

const express        = require('express');
const router         = express.Router();
const verifyToken    = require('../middleware/verifyToken');
const { getMatches, getStats } = require('../controllers/matchController');

// GET /api/requests/:id/matches — butuh login
router.get('/requests/:id/matches', verifyToken, getMatches);

// GET /api/stats — publik
router.get('/stats', getStats);

module.exports = router;
