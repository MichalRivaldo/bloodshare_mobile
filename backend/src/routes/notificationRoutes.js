'use strict';

const { Router } = require('express');
const verifyToken = require('../middleware/verifyToken');
const { getNotifications, markRead } = require('../controllers/notificationController');

const router = Router();

// GET /api/notifications
router.get('/', verifyToken, getNotifications);

// PATCH /api/notifications/:id/read
router.patch('/:id/read', verifyToken, markRead);

module.exports = router;
