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
