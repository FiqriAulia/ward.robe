# Wardrobe untuk macOS

Versi native (SwiftUI + SwiftData) dari Wardrobe. Fiturnya sama dengan versi
web (Input, Laundri[ed], Edit, Sold, Wardrobe, Dress Me, plus easter egg),
tapi tanpa server: semua data tersimpan lokal di Mac.

Butuh macOS 14 (Sonoma) atau lebih baru dan Xcode 16 atau lebih baru.

## Menjalankan

**Lewat Xcode (untuk development):**

```sh
open macos/Package.swift
```

Pilih scheme `Wardrobe`, lalu Run (⌘R).

**Lewat Terminal:**

```sh
cd macos
swift run Wardrobe
```

## Membuat Wardrobe.app

```sh
cd macos
./scripts/build-app.sh
open build/Wardrobe.app
```

Setiap push ke folder `macos/` juga mem-build app ini di GitHub Actions
(workflow "macOS app"). Hasilnya bisa diunduh dari tab **Actions**, di bagian
*Artifacts* → `Wardrobe-macOS`. App-nya hanya ditandatangani ad-hoc, jadi saat
pertama kali dibuka: klik kanan → **Open**, atau jalankan
`xattr -dr com.apple.quarantine Wardrobe.app`.

## Struktur

| Folder | Isi |
|---|---|
| `Sources/WardrobeCore` | Logika murni (jenis pakaian, validasi, algoritma Dress Me). Bisa di-build & dites di Linux. |
| `Sources/Wardrobe` | App SwiftUI: model SwiftData, pemrosesan foto, dan semua layar. |
| `Tests/WardrobeCoreTests` | Unit test untuk WardrobeCore (`swift test`). |

Data disimpan di `~/Library/Application Support/Wardrobe/`. Foto diperkecil
otomatis (maks. 2048 px) dan dibuatkan thumbnail supaya daftar tetap cepat.

## Perbedaan dengan versi web

- Tidak perlu login atau database MySQL; data dilindungi akun macOS Anda.
- Nomor pakaian tidak perlu diisi.
- Deskripsi opsional.
- Foto bisa di-drag dari Finder atau Photos.
- Laundry mendukung aksesoris.
- Dress Me tidak memilih pakaian yang sedang di laundry.
