'use strict';

const { Router } = require('express');
const { healthCheck } = require('../controllers/healthController');

const router = Router();

/**
 * GET /api/health
 */
router.get('/', healthCheck);

module.exports = router;
