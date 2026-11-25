# 🩸 BloodShare

**BloodShare** adalah aplikasi sosial donor darah mandiri & darurat berbasis komunitas. Warga dapat saling meminta bantuan donor darah secara darurat, menjadwalkan donor bersama, dan membangun rekam jejak donasi mereka.

---

## 📋 Fitur Rencana

### 🆘 Permintaan Darah Darurat
- Buat permintaan donor darah dengan informasi golongan darah, lokasi, dan urgensi
- Notifikasi push ke donor terdekat yang cocok
- Respons cepat dari pendonor sukarela di komunitas

### 📅 Jadwal Donor Bersama
- Buat & bergabung acara donor darah komunitas
- Manajemen peserta dan kapasitas acara
- Reminder otomatis sebelum acara

### 👤 Profil Pendonor
- Riwayat donasi lengkap
- Badge & pencapaian donasi
- Verifikasi golongan darah

### 🔔 Notifikasi
- Notifikasi permintaan darah darurat di area terdekat
- Update status permintaan secara real-time
- Pengingat jadwal donor

### 🗺️ Berbasis Lokasi
- Filter permintaan berdasarkan kota
- Cari pendonor di sekitar lokasi rumah sakit

---

## 🛠️ Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Backend | Node.js + Express.js |
| Database | MySQL via XAMPP |
| Auth | JWT (jsonwebtoken) + bcrypt |
| State Management | (TBD - GetX / Riverpod) |

---

## 📁 Struktur Proyek

```
bloodshare/
├── backend/          # Node.js + Express REST API
│   ├── src/
│   │   ├── config/   # Konfigurasi DB, env
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── routes/
│   │   └── utils/
│   ├── database/
│   │   ├── schema.sql
│   │   └── seed.sql
│   ├── .env.example
│   └── package.json
├── mobile/           # Flutter app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
└── docs/             # Dokumentasi tambahan
```

---

## 🚀 Cara Menjalankan

### Prasyarat
- [XAMPP](https://www.apachefriends.org/) (MySQL aktif)
- [Node.js](https://nodejs.org/) v18+
- [Flutter](https://flutter.dev/) SDK 3.x
- [Git](https://git-scm.com/)

### 1. Clone Repositori
```bash
git clone https://github.com/<username>/bloodshare.git
cd bloodshare
```

### 2. Setup Database (via phpMyAdmin)

1. Buka **phpMyAdmin** di `http://localhost/phpmyadmin`
2. Buat database baru bernama `bloodshare`
3. Pilih database `bloodshare`, klik tab **SQL** atau **Import**
4. Import file schema terlebih dahulu:
   - Klik **Import** → pilih file `backend/database/schema.sql` → klik **Go**
5. Import data dummy:
   - Klik **Import** → pilih file `backend/database/seed.sql` → klik **Go**

### 3. Setup Backend
```bash
cd backend
cp .env.example .env
# Edit .env sesuai konfigurasi XAMPP lokal Anda
npm install
npm run dev
```

Backend akan berjalan di `http://localhost:3000`

Cek koneksi: `GET http://localhost:3000/api/health`

### 4. Jalankan Flutter App
```bash
cd mobile
flutter pub get
flutter run
```

---

## 🌐 API Endpoints (Rencana)

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/health` | Cek status server & DB |
| POST | `/api/auth/register` | Registrasi user baru |
| POST | `/api/auth/login` | Login & dapat JWT |
| GET | `/api/blood-requests` | Daftar permintaan darah |
| POST | `/api/blood-requests` | Buat permintaan baru |
| GET | `/api/events` | Daftar acara donor |
| POST | `/api/events` | Buat acara donor |

---

## 👥 Kontribusi

Proyek ini masih dalam tahap pengembangan aktif. Silakan buka _issue_ untuk melaporkan bug atau mengusulkan fitur.

---

## 📄 Lisensi

MIT License — bebas digunakan dan dimodifikasi.

