<div align="center">

<img src="docs/brand.svg" alt="Livia Panel" width="88" height="88">

# Livia Panel

<p>
  <img src="https://img.shields.io/badge/Lua-2C2D72?style=flat&logo=lua&logoColor=white" alt="Lua">
  <img src="https://img.shields.io/badge/Roblox-Utility%20UI-202A43?style=flat&logo=roblox&logoColor=white" alt="Roblox utility UI">
  <img src="https://img.shields.io/badge/Touch--friendly-Mobile-4B82FF?style=flat&logo=android&logoColor=white" alt="Touch friendly">
  <img src="https://img.shields.io/badge/Single--file-Script-35C9DD?style=flat" alt="Single file script">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-27B58A?style=flat" alt="MIT License"></a>
</p>

<p><a href="README.md">Bahasa Indonesia</a> · <a href="README.en.md">English</a></p>

<p><strong>Satu panel. Lima kontrol. Dibuat untuk layar sentuh.</strong><br>
Speed, Jump, Fly, No Clip, dan Flashlight dalam satu skrip Lua yang ringkas, dapat digeser, dan dapat diminimalkan.</p>

<p>
  <a href="#mulai-cepat">Mulai cepat</a> ·
  <a href="#fitur">Fitur</a> ·
  <a href="#panduan-penggunaan">Panduan</a> ·
  <a href="#batasan-dan-keamanan">Keamanan</a> ·
  <a href="#pengembangan">Pengembangan</a>
</p>

</div>

---

![Ilustrasi antarmuka Livia Panel](docs/screenshots/banner.id.svg)

## Tentang proyek

**Livia Panel** adalah skrip Lua satu file untuk lingkungan Roblox yang mendukung dan mengizinkan eksekusi skrip sisi klien. Panel menggabungkan kontrol gerakan dan pencahayaan dalam UI bertema gelap dengan aksen indigo-sian, target sentuh besar, dan kontrol panel yang sederhana.

Tidak membutuhkan library UI eksternal. File utama ada di [`LiviaPanel.lua`](LiviaPanel.lua).

> **Catatan:** gambar di README merupakan ilustrasi antarmuka untuk dokumentasi, bukan tangkapan layar langsung dari Roblox. Perilaku skrip tetap bergantung pada game dan lingkungan eksekusi.

## Mulai cepat

1. Buka [`LiviaPanel.lua`](LiviaPanel.lua).
2. Salin skrip dan jalankan hanya pada pengalaman milikmu atau lingkungan yang secara eksplisit mengizinkan skrip Lua sisi klien.
3. Ketuk tombol **OFF** untuk mengaktifkan fitur. Untuk Speed, Jump, dan Fly, sesuaikan nilai angkanya.
4. Geser panel melalui area header. Gunakan tombol minus untuk minimize atau **X** untuk menutup dan membersihkan fitur.

Opsional: pemuatan dari URL mentah pada lingkungan yang memang mendukung `loadstring` dan `HttpGet`:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/akndrn000/LiviaPanel.lua/main/LiviaPanel.lua"))()
~~~

## Fitur

![Ringkasan fitur Livia Panel](docs/screenshots/features.id.svg)

| Fitur | Nilai awal | Fungsi |
| --- | ---: | --- |
| **Speed** | 50 | Mengatur `Humanoid.WalkSpeed` saat aktif. |
| **Jump** | 100 | Mengatur `Humanoid.JumpPower` saat aktif. |
| **Fly** | 60 | Gerak udara dengan arah joystick dan orientasi kamera. |
| **No Clip** | OFF | Mengubah `CanCollide` pada bagian karakter lokal dan mencatat nilai awal untuk pemulihan. |
| **Flashlight** | OFF | Menambahkan `SpotLight` lokal pada kepala atau `HumanoidRootPart` jika tersedia. |
| **Panel** | — | Panel bisa digeser, diminimalkan menjadi tombol **L**, dan ditutup. |

## Panduan penggunaan

![Alur penggunaan Livia Panel](docs/screenshots/workflow.id.svg)

### Kontrol panel

![Panduan kontrol panel](docs/screenshots/controls.id.svg)

| Aksi | Hasil |
| --- | --- |
| Ketuk toggle | Mengubah status ON/OFF. |
| Geser lebih dari 10 px | Memindahkan panel tanpa sengaja mengaktifkan tombol. |
| Tombol minus | Menyembunyikan panel utama dan menampilkan tombol **L** untuk membuka kembali. |
| Tombol X | Menjalankan cleanup, menghentikan fitur yang dikelola, memutus koneksi event, dan menghapus UI. |

### Menggunakan Fly

![Panduan Fly](docs/screenshots/fly.id.svg)

Joystick menentukan arah gerak. Saat bergerak maju, arah pandang kamera ikut memengaruhi gerak naik/turun. Lepaskan joystick untuk menghentikan gerak.

## Nilai bawaan dan pemulihan

| Fitur | Saat OFF |
| --- | --- |
| Speed | `WalkSpeed` diatur kembali ke 16. |
| Jump | `JumpPower` diatur kembali ke 50. |
| Fly | Gaya gerak terbang yang dibuat skrip dihapus. |
| No Clip | Nilai `CanCollide` yang tercatat dipulihkan untuk bagian karakter yang masih ada. |
| Flashlight | `SpotLight` yang dibuat skrip dihapus. |

> Speed dan Jump memakai nilai pemulihan tetap, yaitu 16 dan 50. Pengalaman dengan sistem gerak khusus mungkin memiliki nilai default berbeda. Perubahan fisika juga dapat dikoreksi oleh server.

## Batasan dan keamanan

![Catatan keamanan dan batasan](docs/screenshots/safety.id.svg)

- **Perilaku sisi klien:** perubahan lokal tidak selalu direplikasi ke server. Game dapat mengabaikan atau mengoreksi perubahan gerakan.
- **No Clip:** hanya mengubah properti `CanCollide` pada karakter yang diproses skrip. Ini tidak menjamin dapat melewati sistem tabrakan yang dikendalikan server.
- **Flashlight:** cahaya dibuat secara lokal; tampilan dan jangkauan bergantung pada pencahayaan pengalaman.
- **Kompatibilitas:** Roblox atau game dapat berubah sehingga skrip tidak lagi berfungsi seperti sebelumnya.
- **Gunakan secara bertanggung jawab:** jalankan hanya di pengalaman milikmu atau lingkungan yang secara eksplisit mengizinkan skrip pihak ketiga. Patuhi aturan pembuat pengalaman dan ketentuan Roblox.
- Skrip ini tidak membutuhkan kata sandi, cookie, atau kredensial akun.

## Pengembangan

Skrip utama sengaja dipertahankan sebagai satu file. Ilustrasi README adalah SVG dan dapat dibuat ulang tanpa paket Python eksternal.

~~~bash
python3 docs/generate-images.py
~~~

Perintah di atas menghasilkan ilustrasi Bahasa Indonesia dan Inggris di `docs/screenshots/` serta logo di `docs/brand.svg`.

### Struktur repositori

~~~text
LiviaPanel.lua
README.md
README.en.md
LICENSE
docs/
├── generate-images.py
├── brand.svg
└── screenshots/
    ├── banner.id.svg / banner.en.svg
    ├── preview.id.svg / preview.en.svg
    ├── features.id.svg / features.en.svg
    ├── workflow.id.svg / workflow.en.svg
    ├── controls.id.svg / controls.en.svg
    ├── fly.id.svg / fly.en.svg
    ├── safety.id.svg / safety.en.svg
    └── social-preview.svg
~~~

## Kontribusi

Laporan bug dan usulan perbaikan dipersilakan melalui Issues atau Pull Requests. Sertakan langkah reproduksi yang jelas dan, bila relevan, pembaruan untuk README Bahasa Indonesia/Inggris serta ilustrasi yang terkait. Jangan sertakan informasi pribadi atau kredensial akun.

## Lisensi

Dirilis di bawah [MIT License](LICENSE).

---

<div align="center">
  <sub>Livia Panel · Lua satu file, kontrol ringkas, dan UI yang mengutamakan sentuhan.</sub>
</div>
