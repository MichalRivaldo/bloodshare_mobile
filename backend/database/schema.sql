-- ============================================================
-- BloodShare Database Schema
-- Engine: InnoDB | Charset: utf8mb4 | Collation: utf8mb4_unicode_ci
-- Import via phpMyAdmin: pilih database `bloodshare` → Import → pilih file ini
-- ============================================================

CREATE DATABASE IF NOT EXISTS `bloodshare`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `bloodshare`;

-- ============================================================
-- Tabel: users
-- Menyimpan data semua pengguna (pendonor & pemohon)
-- ============================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id`              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `nama_lengkap`    VARCHAR(100)      NOT NULL,
  `email`           VARCHAR(150)      NOT NULL,
  `password_hash`   VARCHAR(255)      NOT NULL,
  `no_telepon`      VARCHAR(20)       NOT NULL,
  `golongan_darah`  ENUM('A','B','AB','O') NULL,
  `rhesus`          ENUM('+','-')     NULL,
  `kota`            VARCHAR(100)      NULL,
  `alamat`          TEXT              NULL,
  `tanggal_lahir`   DATE              NULL,
  `jenis_kelamin`   ENUM('L','P')     NULL,
  `foto_profil`     VARCHAR(255)      NULL,
  `is_donor_aktif`  TINYINT(1)        NOT NULL DEFAULT 1 COMMENT '1=siap donor, 0=tidak tersedia',
  `last_donor_at`   DATE              NULL     COMMENT 'Tanggal terakhir donor darah',
  `total_donasi`    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `is_verified`     TINYINT(1)        NOT NULL DEFAULT 0,
  `role`            ENUM('user','admin') NOT NULL DEFAULT 'user',
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_email` (`email`),
  UNIQUE KEY `uq_telepon` (`no_telepon`),
  INDEX `idx_golongan_darah` (`golongan_darah`),
  INDEX `idx_kota` (`kota`),
  INDEX `idx_is_donor_aktif` (`is_donor_aktif`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Data pengguna BloodShare';


-- ============================================================
-- Tabel: blood_requests
-- Permintaan donor darah (darurat maupun terjadwal)
-- ============================================================
CREATE TABLE IF NOT EXISTS `blood_requests` (
  `id`              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `requester_id`    INT UNSIGNED      NOT NULL COMMENT 'FK → users.id',
  `golongan_darah`  ENUM('A','B','AB','O') NOT NULL,
  `rhesus`          ENUM('+','-')     NOT NULL,
  `jumlah_kantong`  TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  `urgensi`         ENUM('darurat','segera','terjadwal') NOT NULL DEFAULT 'segera',
  `nama_pasien`     VARCHAR(100)      NOT NULL,
  `nama_rs`         VARCHAR(150)      NOT NULL COMMENT 'Nama rumah sakit/klinik',
  `kota`            VARCHAR(100)      NOT NULL,
  `alamat_rs`       TEXT              NULL,
  `tanggal_dibutuhkan` DATE           NOT NULL,
  `keterangan`      TEXT              NULL,
  `status`          ENUM('aktif','terpenuhi','dibatalkan','kadaluarsa') NOT NULL DEFAULT 'aktif',
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_br_requester` FOREIGN KEY (`requester_id`)
    REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX `idx_br_golongan_darah` (`golongan_darah`),
  INDEX `idx_br_kota` (`kota`),
  INDEX `idx_br_status` (`status`),
  INDEX `idx_br_urgensi` (`urgensi`),
  INDEX `idx_br_tanggal` (`tanggal_dibutuhkan`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Permintaan donor darah dari pengguna';


-- ============================================================
-- Tabel: request_responses
-- Respons pendonor terhadap permintaan darah
-- ============================================================
CREATE TABLE IF NOT EXISTS `request_responses` (
  `id`              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `request_id`      INT UNSIGNED      NOT NULL COMMENT 'FK → blood_requests.id',
  `donor_id`        INT UNSIGNED      NOT NULL COMMENT 'FK → users.id',
  `pesan`           TEXT              NULL,
  `status`          ENUM('menunggu','dikonfirmasi','selesai','dibatalkan') NOT NULL DEFAULT 'menunggu',
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_rr_request` FOREIGN KEY (`request_id`)
    REFERENCES `blood_requests` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rr_donor` FOREIGN KEY (`donor_id`)
    REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `uq_rr_request_donor` (`request_id`, `donor_id`),
  INDEX `idx_rr_status` (`status`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Respons pendonor terhadap permintaan darah';


-- ============================================================
-- Tabel: donor_events
-- Acara donor darah bersama yang dibuat komunitas
-- ============================================================
CREATE TABLE IF NOT EXISTS `donor_events` (
  `id`              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `organizer_id`    INT UNSIGNED      NOT NULL COMMENT 'FK → users.id',
  `judul`           VARCHAR(200)      NOT NULL,
  `deskripsi`       TEXT              NULL,
  `nama_lokasi`     VARCHAR(200)      NOT NULL,
  `kota`            VARCHAR(100)      NOT NULL,
  `alamat`          TEXT              NULL,
  `tanggal_mulai`   DATETIME          NOT NULL,
  `tanggal_selesai` DATETIME          NOT NULL,
  `kuota`           SMALLINT UNSIGNED NOT NULL DEFAULT 50,
  `status`          ENUM('akan_datang','berlangsung','selesai','dibatalkan') NOT NULL DEFAULT 'akan_datang',
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_de_organizer` FOREIGN KEY (`organizer_id`)
    REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX `idx_de_kota` (`kota`),
  INDEX `idx_de_status` (`status`),
  INDEX `idx_de_tanggal` (`tanggal_mulai`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Acara donor darah komunitas';


-- ============================================================
-- Tabel: event_participants
-- Peserta yang mendaftar ke acara donor
-- ============================================================
CREATE TABLE IF NOT EXISTS `event_participants` (
  `id`              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `event_id`        INT UNSIGNED      NOT NULL COMMENT 'FK → donor_events.id',
  `user_id`         INT UNSIGNED      NOT NULL COMMENT 'FK → users.id',
  `status`          ENUM('terdaftar','hadir','tidak_hadir','dibatalkan') NOT NULL DEFAULT 'terdaftar',
  `catatan`         TEXT              NULL,
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_ep_event` FOREIGN KEY (`event_id`)
    REFERENCES `donor_events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ep_user` FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `uq_ep_event_user` (`event_id`, `user_id`),
  INDEX `idx_ep_status` (`status`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Daftar peserta acara donor';


-- ============================================================
-- Tabel: donation_history
-- Riwayat donasi darah yang telah selesai dilakukan
-- ============================================================
CREATE TABLE IF NOT EXISTS `donation_history` (
  `id`              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `donor_id`        INT UNSIGNED      NOT NULL COMMENT 'FK → users.id',
  `request_id`      INT UNSIGNED      NULL     COMMENT 'FK → blood_requests.id (nullable jika dari event)',
  `event_id`        INT UNSIGNED      NULL     COMMENT 'FK → donor_events.id (nullable jika dari request)',
  `tanggal_donor`   DATE              NOT NULL,
  `lokasi`          VARCHAR(200)      NULL,
  `kota`            VARCHAR(100)      NULL,
  `golongan_darah`  ENUM('A','B','AB','O') NOT NULL,
  `jumlah_kantong`  TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  `keterangan`      TEXT              NULL,
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_dh_donor` FOREIGN KEY (`donor_id`)
    REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dh_request` FOREIGN KEY (`request_id`)
    REFERENCES `blood_requests` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_dh_event` FOREIGN KEY (`event_id`)
    REFERENCES `donor_events` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX `idx_dh_donor_id` (`donor_id`),
  INDEX `idx_dh_tanggal` (`tanggal_donor`),
  INDEX `idx_dh_golongan` (`golongan_darah`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Riwayat donasi darah selesai';


-- ============================================================
-- Tabel: notifications
-- Notifikasi in-app untuk setiap pengguna
-- ============================================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id`              INT UNSIGNED      NOT NULL AUTO_INCREMENT,
  `user_id`         INT UNSIGNED      NOT NULL COMMENT 'FK → users.id (penerima notifikasi)',
  `judul`           VARCHAR(200)      NOT NULL,
  `pesan`           TEXT              NOT NULL,
  `tipe`            ENUM('permintaan_darah','respons_donor','event','sistem','reminder') NOT NULL DEFAULT 'sistem',
  `ref_id`          INT UNSIGNED      NULL     COMMENT 'ID referensi (request_id / event_id dll)',
  `ref_tipe`        VARCHAR(50)       NULL     COMMENT 'Tipe referensi: blood_request / donor_event',
  `is_read`         TINYINT(1)        NOT NULL DEFAULT 0,
  `created_at`      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX `idx_notif_user_id` (`user_id`),
  INDEX `idx_notif_is_read` (`is_read`),
  INDEX `idx_notif_tipe` (`tipe`)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Notifikasi in-app pengguna';

