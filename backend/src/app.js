'use strict';

require('dotenv').config();

const express = require('express');
const cors    = require('cors');

// ── Middleware ──────────────────────────────────────────────
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

// ── Routes ──────────────────────────────────────────────────
const healthRoutes = require('./routes/healthRoutes');

// ── App ─────────────────────────────────────────────────────
const app  = express();
const PORT = process.env.PORT || 3000;

// Body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS — izinkan semua origin saat development; batasi di production
app.use(cors({
  origin:      process.env.NODE_ENV === 'production' ? process.env.ALLOWED_ORIGINS : '*',
  credentials: true,
}));

// ── API Routes ───────────────────────────────────────────────
app.use('/api/health', healthRoutes);

// Tambahkan route lain di sini seiring perkembangan tahap:
// app.use('/api/auth',          authRoutes);
// app.use('/api/blood-requests', bloodRequestRoutes);
// app.use('/api/events',         eventRoutes);

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
