'use strict';

require('dotenv').config();

const express = require('express');
const cors    = require('cors');

// ── Middleware ──────────────────────────────────────────────
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

// ── Routes ──────────────────────────────────────────────────
const healthRoutes       = require('./routes/healthRoutes');
const authRoutes         = require('./routes/authRoutes');
const userRoutes         = require('./routes/userRoutes');
const bloodRequestRoutes = require('./routes/bloodRequestRoutes');
const responseRoutes     = require('./routes/responseRoutes');
const { responseRouter } = require('./routes/responseRoutes');
const notificationRoutes = require('./routes/notificationRoutes');

// ── App ─────────────────────────────────────────────────────
const app  = express();
const PORT = process.env.PORT || 3000;

// Body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS
app.use(cors({
  origin:      process.env.NODE_ENV === 'production' ? process.env.ALLOWED_ORIGINS : '*',
  credentials: true,
}));

// ── API Routes ───────────────────────────────────────────────
app.use('/api/health',        healthRoutes);
app.use('/api/auth',          authRoutes);
app.use('/api/users',         userRoutes);
app.use('/api/requests',      bloodRequestRoutes);
app.use('/api/requests',      responseRoutes);      // POST /api/requests/:id/respond
app.use('/api/responses',     responseRouter);      // PATCH /api/responses/:id
app.use('/api/notifications', notificationRoutes);

// ── 404 & Error Handler (harus di paling bawah) ──────────────
app.use(notFoundHandler);
app.use(errorHandler);

// ── Start Server ─────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🩸 BloodShare API berjalan di http://localhost:${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🌍 Environment : ${process.env.NODE_ENV || 'development'}\n`);
});

module.exports = app;
