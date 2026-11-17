-- ============================================================
-- BloodShare — Seed Data (Data Dummy)
-- Jalankan SETELAH schema.sql berhasil diimport
-- ============================================================

USE `bloodshare`;

-- ============================================================
-- Users (10 dummy users)
-- Password semua: "Password123!" → hash bcrypt (cost 10)
-- Hash di bawah hanya ilustrasi; ganti dengan hash nyata saat produksi
-- ============================================================
INSERT INTO `users`
  (`nama_lengkap`, `email`, `password_hash`, `no_telepon`, `golongan_darah`, `rhesus`, `kota`, `alamat`, `tanggal_lahir`, `jenis_kelamin`, `is_donor_aktif`, `last_donor_at`, `total_donasi`, `is_verified`, `role`)
VALUES
  -- 1
  ('Andi Pratama',       'andi.pratama@email.com',    '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567001', 'A',  '+', 'Jakarta',    'Jl. Sudirman No. 10, Jakarta Pusat',          '1990-05-15', 'L', 1, '2026-08-20', 12, 1, 'user'),
  -- 2
  ('Budi Santoso',       'budi.santoso@email.com',    '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567002', 'B',  '+', 'Bandung',    'Jl. Dago No. 55, Bandung',                    '1988-11-23', 'L', 1, '2026-07-10', 8,  1, 'user'),
  -- 3
  ('Citra Dewi',         'citra.dewi@email.com',      '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567003', 'O',  '+', 'Surabaya',   'Jl. Pemuda No. 33, Surabaya',                 '1995-03-08', 'P', 1, '2026-09-05', 5,  1, 'user'),
  -- 4
  ('Dian Rahayu',        'dian.rahayu@email.com',     '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567004', 'AB', '+', 'Yogyakarta', 'Jl. Malioboro No. 7, Yogyakarta',             '1993-07-19', 'P', 0, '2026-06-15', 3,  1, 'user'),
  -- 5
  ('Eko Wijaya',         'eko.wijaya@email.com',      '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567005', 'A',  '+', 'Jakarta',    'Jl. Gatot Subroto No. 88, Jakarta Selatan',   '1985-12-30', 'L', 1, '2026-05-01', 20, 1, 'user'),
  -- 6
  ('Fitri Handayani',    'fitri.handayani@email.com', '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567006', 'B',  '-', 'Medan',      'Jl. Sisingamangaraja No. 12, Medan',          '1997-01-25', 'P', 1, NULL,         0,  0, 'user'),
  -- 7
  ('Galih Permana',      'galih.permana@email.com',   '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567007', 'O',  '+', 'Semarang',   'Jl. Pandanaran No. 20, Semarang',             '1991-09-14', 'L', 1, '2026-10-11', 7,  1, 'user'),
  -- 8
  ('Hana Kusuma',        'hana.kusuma@email.com',     '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567008', 'A',  '-', 'Surabaya',   'Jl. Basuki Rahmat No. 45, Surabaya',          '1996-06-02', 'P', 1, '2026-09-22', 2,  1, 'user'),
  -- 9
  ('Ivan Gunawan',       'ivan.gunawan@email.com',    '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567009', 'O',  '-', 'Bandung',    'Jl. Braga No. 9, Bandung',                    '1989-04-18', 'L', 0, '2026-11-01', 15, 1, 'user'),
  -- 10 (admin)
  ('Admin BloodShare',   'admin@bloodshare.id',       '$2b$10$KIX8X5k0pUQZvJTSvOeIZOoGQp7Q4R2tHk3LlNmQyXpWfVbCsDe6u', '081234567000', 'O',  '+', 'Jakarta',    'Kantor BloodShare, Jakarta',                  '1990-01-01', 'L', 0, NULL,         0,  1, 'admin');


-- ============================================================
-- Blood Requests (6 permintaan dummy)
-- ============================================================
INSERT INTO `blood_requests`
  (`requester_id`, `golongan_darah`, `rhesus`, `jumlah_kantong`, `urgensi`, `nama_pasien`, `nama_rs`, `kota`, `alamat_rs`, `tanggal_dibutuhkan`, `keterangan`, `status`)
VALUES
  -- 1: Permintaan darurat B+
  (3, 'B', '+', 2, 'darurat',    'Bapak Suharto',   'RSUD Dr. Soetomo',           'Surabaya',   'Jl. Mayjen Prof. Dr. Moestopo No.6-8, Surabaya', '2026-11-18', 'Pasien kecelakaan, operasi mendesak, butuh 2 kantong B+.',          'aktif'),
  -- 2: Permintaan segera O+
  (1, 'O', '+', 1, 'segera',     'Ibu Sari',        'RS Cipto Mangunkusumo',      'Jakarta',    'Jl. Diponegoro No.71, Jakarta Pusat',            '2026-11-20', 'Pasien operasi caesar, stok darah RS menipis.',                     'aktif'),
  -- 3: Permintaan terjadwal A+
  (5, 'A', '+', 3, 'terjadwal',  'Tn. Hendra',      'RS Siloam Kebon Jeruk',      'Jakarta',    'Jl. Perjuangan No.8, Jakarta Barat',             '2026-11-25', 'Pasien kemoterapi rutin, butuh stok darah A+ setiap bulan.',        'aktif'),
  -- 4: Permintaan AB+ (langka)
  (7, 'AB', '+', 1, 'darurat',   'Ny. Wulandari',   'RSUP Dr. Kariadi',           'Semarang',   'Jl. Dr. Sutomo No.16, Semarang',                 '2026-11-18', 'Golongan AB+ sangat dibutuhkan segera untuk pasien DBD.',           'aktif'),
  -- 5: Sudah terpenuhi
  (2, 'B', '+', 1, 'segera',     'Anak Doni',       'RS Hasan Sadikin',           'Bandung',    'Jl. Pasteur No.38, Bandung',                     '2026-11-15', 'Anak usia 8 tahun, thalasemia.',                                   'terpenuhi'),
  -- 6: Permintaan O- (paling langka)
  (8, 'O', '-', 2, 'darurat',    'Bp. Sugiarto',    'RSUD Dr. Pirngadi',          'Medan',      'Jl. Prof. H.M. Yamin No.47, Medan',              '2026-11-19', 'Golongan O- sangat langka. Pasien perlu transfusi segera.',         'aktif');


-- ============================================================
-- Request Responses (beberapa respons)
-- ============================================================
INSERT INTO `request_responses`
  (`request_id`, `donor_id`, `pesan`, `status`)
VALUES
  (1, 2,  'Saya bersedia donor B+, bisa datang besok pagi.', 'dikonfirmasi'),
  (2, 1,  'Saya O+, bisa bantu. Nomor saya 081234567001.',   'menunggu'),
  (2, 5,  'Siap membantu, lokasi tidak jauh dari RS.',       'menunggu'),
  (5, 2,  'Sudah donor kemarin, terima kasih atas kepercayaannya.', 'selesai');


-- ============================================================
-- Donor Events (2 acara)
-- ============================================================
INSERT INTO `donor_events`
  (`organizer_id`, `judul`, `deskripsi`, `nama_lokasi`, `kota`, `alamat`, `tanggal_mulai`, `tanggal_selesai`, `kuota`, `status`)
VALUES
  (10, 'Donor Darah Hari Pahlawan 2026',
       'Acara donor darah massal dalam rangka memperingati Hari Pahlawan Nasional. Terbuka untuk umum, gratis pemeriksaan kesehatan.',
       'Balai Kota Jakarta', 'Jakarta', 'Jl. Medan Merdeka Selatan No.8-9, Jakarta Pusat',
       '2026-11-20 08:00:00', '2026-11-20 14:00:00', 200, 'akan_datang'),

  (7,  'Donor Darah Komunitas Semarang #3',
       'Kegiatan donor darah rutin bulanan komunitas BloodShare Semarang. Tersedia snack dan sertifikat.',
       'Gedung Pandanaran Convention Hall', 'Semarang', 'Jl. Pandanaran No.100, Semarang',
       '2026-11-28 09:00:00', '2026-11-28 13:00:00', 100, 'akan_datang');


-- ============================================================
-- Event Participants
-- ============================================================
INSERT INTO `event_participants`
  (`event_id`, `user_id`, `status`)
VALUES
  (1, 1, 'terdaftar'),
  (1, 3, 'terdaftar'),
  (1, 5, 'terdaftar'),
  (1, 8, 'terdaftar'),
  (2, 7, 'terdaftar'),
  (2, 2, 'terdaftar'),
  (2, 9, 'terdaftar');


-- ============================================================
-- Donation History
-- ============================================================
INSERT INTO `donation_history`
  (`donor_id`, `request_id`, `event_id`, `tanggal_donor`, `lokasi`, `kota`, `golongan_darah`, `jumlah_kantong`, `keterangan`)
VALUES
  (1, NULL, NULL, '2026-08-20', 'PMI Jakarta Pusat',       'Jakarta',    'A', 1, 'Donor rutin PMI'),
  (2, 5,    NULL, '2026-11-15', 'RS Hasan Sadikin Bandung','Bandung',    'B', 1, 'Membantu permintaan darurat anak thalasemia'),
  (5, NULL, NULL, '2026-05-01', 'PMI Jakarta Selatan',     'Jakarta',    'A', 1, 'Donor ke-20, mendapat pin emas'),
  (7, NULL, NULL, '2026-10-11', 'PMI Semarang',            'Semarang',   'O', 1, 'Donor rutin bulanan'),
  (9, NULL, NULL, '2026-11-01', 'RS Hasan Sadikin Bandung','Bandung',    'O', 1, 'Donor sukarela');


-- ============================================================
-- Notifications
-- ============================================================
INSERT INTO `notifications`
  (`user_id`, `judul`, `pesan`, `tipe`, `ref_id`, `ref_tipe`, `is_read`)
VALUES
  (2, 'Ada permintaan B+ di Surabaya!',
      'Seseorang membutuhkan donor darah B+ segera di RSUD Dr. Soetomo, Surabaya.',
      'permintaan_darah', 1, 'blood_request', 0),
  (1, 'Ada permintaan O+ di Jakarta!',
      'Seseorang membutuhkan donor darah O+ di RS Cipto Mangunkusumo, Jakarta.',
      'permintaan_darah', 2, 'blood_request', 0),
  (1, 'Respons Anda sedang ditinjau',
      'Pemilik permintaan akan segera menghubungi Anda. Terima kasih telah bersedia membantu!',
      'respons_donor', 2, 'blood_request', 0),
  (3, 'Acara Donor Darah Hari Pahlawan 2026',
      'Jangan lupa! Acara donor darah di Balai Kota Jakarta pada 20 November 2026 pukul 08.00.',
      'event', 1, 'donor_event', 1),
  (7, 'Permintaan AB+ Darurat di Semarang!',
      'Ada permintaan darah AB+ darurat di RSUP Dr. Kariadi, Semarang. Golongan Anda cocok!',
      'permintaan_darah', 4, 'blood_request', 0),
  (10, 'Pengguna baru terdaftar',
       'Fitri Handayani baru saja mendaftar dan menunggu verifikasi.',
       'sistem', NULL, NULL, 0);
