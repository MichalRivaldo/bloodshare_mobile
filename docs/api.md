# BloodShare API Documentation

Base URL: `http://localhost:3000`

Format response selalu:
```json
{ "success": true|false, "message": "...", "data": null|{...} }
```

---

## Auth Endpoints

### POST `/api/auth/register`
Daftarkan user baru.

**Auth required:** ❌

**Request body:**
```json
{
  "nama_lengkap":  "Budi Santoso",
  "email":         "budi@email.com",
  "password":      "rahasia123",
  "no_telepon":    "08123456789",
  "golongan_darah":"A",
  "rhesus":        "+",
  "kota":          "Jakarta",
  "alamat":        "Jl. Merdeka No.1",   // opsional
  "tanggal_lahir": "1995-06-15",         // opsional
  "jenis_kelamin": "L"                   // opsional, L/P
}
```

**Response 201:**
```json
{
  "success": true,
  "message": "Registrasi berhasil.",
  "data": {
    "user": { "id": 1, "nama_lengkap": "Budi Santoso", "email": "budi@email.com", "..." },
    "token": "<jwt>"
  }
}
```

**Response 409 (email duplikat):**
```json
{ "success": false, "message": "Email sudah terdaftar.", "data": null }
```

**Response 422 (validasi gagal):**
```json
{ "success": false, "message": "Validasi gagal.", "data": [{ "msg": "...", "path": "..." }] }
```

---

### POST `/api/auth/login`
Login user.

**Auth required:** ❌

**Request body:**
```json
{ "email": "budi@email.com", "password": "rahasia123" }
```

**Response 200:**
```json
{
  "success": true,
  "message": "Login berhasil.",
  "data": { "user": { "..." }, "token": "<jwt>" }
}
```

**Response 401:**
```json
{ "success": false, "message": "Email atau password salah.", "data": null }
```

---

### GET `/api/auth/me`
Ambil data user yang sedang login.

**Auth required:** ✅ `Authorization: Bearer <token>`

**Response 200:**
```json
{
  "success": true,
  "message": "Data user berhasil diambil.",
  "data": { "user": { "id": 1, "nama_lengkap": "...", "..." } }
}
```

**Response 401:**
```json
{ "success": false, "message": "Token tidak ditemukan. Harap login terlebih dahulu.", "data": null }
```

---

## User Endpoints

### PUT `/api/users/profile`
Update profil user.

**Auth required:** ✅ `Authorization: Bearer <token>`

**Request body (semua opsional):**
```json
{
  "nama_lengkap":  "Budi Santoso",
  "no_telepon":    "08123456789",
  "kota":          "Bandung",
  "alamat":        "Jl. Sudirman No.5",
  "tanggal_lahir": "1995-06-15",
  "jenis_kelamin": "L",
  "golongan_darah":"AB",
  "rhesus":        "-"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Profil berhasil diperbarui.",
  "data": { "user": { "..." } }
}
```

---

### PATCH `/api/users/availability`
Toggle status donor aktif user (aktif ↔ tidak aktif).

**Auth required:** ✅ `Authorization: Bearer <token>`

**Request body:** _(kosong)_

**Response 200:**
```json
{
  "success": true,
  "message": "Kamu sekarang terdaftar sebagai donor aktif.",
  "data": { "is_donor_aktif": true }
}
```


---

## 🩸 Tahap 4 — Blood Requests API

> Semua endpoint `POST`, `PUT`, `PATCH` membutuhkan header:
> `Authorization: Bearer <token>`

---

### POST /api/requests
Buat permintaan donor darah baru.

**Request Body:**
```json
{
  "golongan_darah": "B",
  "rhesus": "+",
  "jumlah_kantong": 2,
  "urgensi": "darurat",
  "nama_pasien": "Bapak Hendra",
  "nama_rs": "RSUD Dr. Soetomo",
  "kota": "Surabaya",
  "alamat_rs": "Jl. Mayjen Prof. Dr. Moestopo No.6-8",
  "tanggal_dibutuhkan": "2026-11-20",
  "keterangan": "Pasien kecelakaan, operasi mendesak"
}
```

**Response 201:**
```json
{
  "success": true,
  "message": "Permintaan darah berhasil dibuat.",
  "data": { "request": { ...detail permintaan } }
}
```

---

### GET /api/requests
Ambil daftar permintaan dengan filter & pagination. Status `aktif` yang `tanggal_dibutuhkan`-nya sudah lewat otomatis berubah ke `kadaluarsa`.

**Query Params (semua opsional):**
| Param | Contoh | Keterangan |
|---|---|---|
| `golongan_darah` | `B` | Filter A/B/AB/O |
| `rhesus` | `+` | Filter +/- |
| `kota` | `Surabaya` | Partial match |
| `urgensi` | `darurat` | darurat/segera/terjadwal |
| `status` | `aktif` | aktif/terpenuhi/dibatalkan/kadaluarsa |
| `page` | `1` | Halaman (default: 1) |
| `limit` | `10` | Per halaman (default: 10) |

**Response 200:**
```json
{
  "success": true,
  "message": "Daftar permintaan darah.",
  "data": {
    "requests": [ ...array permintaan ],
    "pagination": { "total": 50, "page": 1, "limit": 10, "total_pages": 5 }
  }
}
```

---

### GET /api/requests/:id
Ambil detail satu permintaan beserta data pembuat & jumlah responden.

**Response 200:**
```json
{
  "success": true,
  "message": "Detail permintaan darah.",
  "data": {
    "request": {
      "id": 1,
      "golongan_darah": "B",
      "rhesus": "+",
      "requester_nama": "Citra Dewi",
      "requester_telepon": "081234567003",
      "jumlah_respon": 3,
      ...
    }
  }
}
```

---

### PUT /api/requests/:id
Update data permintaan (hanya pemilik permintaan). Body sama seperti POST.

**Response 200:**
```json
{ "success": true, "message": "Permintaan berhasil diupdate.", "data": { "request": { ... } } }
```

---

### PATCH /api/requests/:id/status
Update hanya status permintaan (hanya pemilik).

**Request Body:**
```json
{ "status": "dibatalkan" }
```
Nilai valid: `aktif`, `terpenuhi`, `dibatalkan`

---

## 🤝 Tahap 5 — Respon Donor & Notifikasi

---

### POST /api/requests/:id/respond
Donor merespon permintaan darah. Tidak bisa merespon permintaan sendiri atau dua kali.

**Request Body (opsional):**
```json
{ "pesan": "Saya bersedia donor B+, bisa datang besok pagi." }
```

**Response 201:**
```json
{
  "success": true,
  "message": "Respon berhasil dikirim. Pemilik permintaan akan segera menghubungi Anda.",
  "data": { "response_id": 5 }
}
```

**Error cases:**
- `400` — Merespon permintaan sendiri
- `409` — Sudah pernah merespon
- `400` — Permintaan tidak lagi aktif

---

### PATCH /api/responses/:id
Pemilik permintaan mengubah status respon donor.

**Request Body:**
```json
{ "status": "dikonfirmasi" }
```
Nilai valid:
| Status | Efek |
|---|---|
| `dikonfirmasi` | Donor diterima → notifikasi dikirim ke donor |
| `dibatalkan` | Donor ditolak → notifikasi dikirim ke donor |
| `selesai` | Donasi selesai → dicatat ke `donation_history`, `last_donor_at` & `total_donasi` donor diupdate, status request jadi `terpenuhi` |

> ⚠️ Operasi `selesai` menggunakan **MySQL transaction** untuk menjaga konsistensi data.

**Response 200:**
```json
{ "success": true, "message": "Status respon diperbarui menjadi \"selesai\".", "data": null }
```

---

### GET /api/notifications
Ambil semua notifikasi milik user yang sedang login.

**Query Params:** `page` (default 1), `limit` (default 20)

**Response 200:**
```json
{
  "success": true,
  "message": "Daftar notifikasi.",
  "data": {
    "notifications": [
      {
        "id": 1,
        "judul": "Ada pendonor yang merespon!",
        "pesan": "Andi Pratama bersedia membantu permintaan darah B+ Anda.",
        "tipe": "respons_donor",
        "is_read": 0,
        "created_at": "2026-11-18T..."
      }
    ],
    "pagination": { "total": 5, "page": 1, "limit": 20, "total_pages": 1 }
  }
}
```

---

### PATCH /api/notifications/:id/read
Tandai satu notifikasi sebagai sudah dibaca.

**Response 200:**
```json
{ "success": true, "message": "Notifikasi ditandai sudah dibaca.", "data": null }
```


---

## 📅 Tahap 6 — Donor Events & Donation History API

---

### GET `/api/events`
Ambil daftar event donor darah dengan filter dan pagination.

**Auth required:** ❌

**Query Params (semua opsional):**
| Param | Contoh | Keterangan |
|---|---|---|
| `kota` | `Jakarta` | Filter exact match kota |
| `status` | `akan_datang` | akan_datang / berlangsung / selesai / dibatalkan |
| `page` | `1` | Halaman (default: 1) |
| `limit` | `10` | Per halaman (default: 10) |

**Response 200:**
```json
{
  "success": true,
  "message": "Daftar event donor darah.",
  "data": {
    "events": [ { "id": 1, "judul": "Donor Darah Merdeka", "kota": "Jakarta", "status": "akan_datang", "..." } ],
    "pagination": { "total": 20, "page": 1, "limit": 10, "total_pages": 2 }
  }
}
```

---

### POST `/api/events`
Buat event donor darah baru.

**Auth required:** ✅ `Authorization: Bearer <token>`

**Request body:**
```json
{
  "judul": "Donor Darah Merdeka",
  "deskripsi": "Event rutin bulanan PMI.",
  "nama_lokasi": "Gedung Serbaguna A",
  "kota": "Jakarta",
  "alamat": "Jl. Sudirman No.10",
  "tanggal_mulai": "2026-12-01",
  "tanggal_selesai": "2026-12-01",
  "kuota": 50
}
```
Wajib: `judul`, `nama_lokasi`, `kota`, `tanggal_mulai`, `tanggal_selesai`, `kuota`.

**Response 201:**
```json
{
  "success": true,
  "message": "Event berhasil dibuat.",
  "data": { "event": { "id": 3, "judul": "Donor Darah Merdeka", "..." } }
}
```

**Response 422 (validasi gagal):**
```json
{ "success": false, "message": "Validasi gagal.", "data": [{ "msg": "Judul wajib diisi.", "path": "judul" }] }
```

---

### GET `/api/events/:id`
Ambil detail event beserta jumlah peserta aktif.

**Auth required:** ❌

**Response 200:**
```json
{
  "success": true,
  "message": "Detail event.",
  "data": {
    "event": {
      "id": 1,
      "judul": "Donor Darah Merdeka",
      "kota": "Jakarta",
      "status": "akan_datang",
      "kuota": 50,
      "jumlah_peserta": 12,
      "..."
    }
  }
}
```

**Response 404:**
```json
{ "success": false, "message": "Event tidak ditemukan.", "data": null }
```

---

### POST `/api/events/:id/join`
Daftar sebagai peserta event.

**Auth required:** ✅ `Authorization: Bearer <token>`

**Response 201:**
```json
{ "success": true, "message": "Berhasil mendaftar ke event.", "data": null }
```

**Error cases:**
- `404` — Event tidak ditemukan
- `400` — Event tidak lagi menerima peserta (status bukan `akan_datang`)
- `409` — Sudah terdaftar di event ini
- `400` — Kuota event sudah penuh

---

### DELETE `/api/events/:id/join`
Batalkan keikutsertaan dari event.

**Auth required:** ✅ `Authorization: Bearer <token>`

**Response 200:**
```json
{ "success": true, "message": "Berhasil keluar dari event.", "data": null }
```

**Error cases:**
- `404` — Kamu tidak terdaftar di event ini

---

### GET `/api/donations/history`
Ambil riwayat donasi darah user yang sedang login, diurutkan dari terbaru.

**Auth required:** ✅ `Authorization: Bearer <token>`

**Query Params (opsional):** `page` (default 1), `limit` (default 10)

**Response 200:**
```json
{
  "success": true,
  "message": "Riwayat donasi.",
  "data": {
    "history": [
      {
        "id": 5,
        "donor_id": 1,
        "event_id": 2,
        "request_id": null,
        "tanggal_donor": "2026-10-01",
        "lokasi": "PMI Jakarta Pusat",
        "kota": "Jakarta",
        "golongan_darah": "A",
        "jumlah_kantong": 1
      }
    ],
    "pagination": { "total": 3, "page": 1, "limit": 10, "total_pages": 1 }
  }
}
```

---

### GET `/api/donations/eligibility`
Cek apakah user saat ini layak untuk mendonor darah (jeda minimal 56 hari sejak donasi terakhir).

**Auth required:** ✅ `Authorization: Bearer <token>`

**Response 200 (belum pernah donor / sudah eligible):**
```json
{
  "success": true,
  "message": "Status kelayakan donor.",
  "data": {
    "isEligible": true,
    "lastDonorAt": "2026-09-01",
    "nextEligibleAt": "2026-10-27",
    "daysRemaining": 0
  }
}
```

**Response 200 (belum eligible):**
```json
{
  "success": true,
  "message": "Status kelayakan donor.",
  "data": {
    "isEligible": false,
    "lastDonorAt": "2026-11-01",
    "nextEligibleAt": "2026-12-27",
    "daysRemaining": 32
  }
}
```

> Jika `lastDonorAt` adalah `null`, berarti user belum pernah donor → `isEligible: true`.
