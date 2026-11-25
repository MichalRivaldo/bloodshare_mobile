'use strict';

const { Router }        = require('express');
const verifyToken       = require('../middleware/verifyToken');
const donationController = require('../controllers/donationController');

const router = Router();

router.get('/history',     verifyToken, donationController.getHistory);
router.get('/eligibility', verifyToken, donationController.getEligibility);

module.exports = router;
