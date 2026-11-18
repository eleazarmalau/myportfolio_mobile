# Catatan penggunaan AI — Assignment 8

Tool yang digunakan: OpenAI Codex. Catatan berikut merupakan kutipan prompt dan
ringkasan bantuan yang relevan, bukan ekspor transkrip percakapan lengkap.

## Arahan sebelum mengerjakan tugas

> udah sesuai dengan kode yang diminta di pdf ini gak? jangan asal ganti ganti harus sesuai tutorial

Pengguna memberikan PDF Tutorial 09. AI membandingkan kode dengan PDF dan
mengoreksi perbedaan pada navigasi snackbar, pemanggilan Navigator, field teks,
import Material UI, serta struktur screens/widgets. Arahan ini menjadi batasan
untuk Assignment 8: pola tutorial tetap dipakai dan perubahan baru harus memiliki
alasan dari checklist.

## Permintaan Assignment 8

> coba sekarang kerjakan bagian this assingment's target dan kerjakan sesuai dengan checklistnya apa aja itu

Lampiran: *Individual Assignment 8: Flutter Navigation, Layouts, Forms, and Input
Elements — PBP Odd Semester 2026/2027*.

AI membaca checklist, lalu memeriksa kode Flutter dan model/serializer di proyek
Django yang sudah tersedia. Education dipilih karena model tersebut sudah ada
dan digunakan pada tugas web sebelumnya.

## Bagian yang dibantu

- `lib/screens/education_form.dart`: StatefulWidget, key form, tujuh field,
  validator, pengelolaan controller, Save, dan dialog ringkasan.
- `lib/widgets/project_card.dart`: `Navigator.push()` untuk Add Education,
  setelah snackbar mengikuti pola tutorial.
- `lib/widgets/left_drawer.dart`: opsi Add Education dengan drawer bersama;
  Home dan Add Project dipertahankan.
- `lib/screens/menu.dart`: kartu Education serta penyesuaian scrolling dan lebar
  kartu agar halaman tetap dapat digunakan pada viewport ponsel.
- `test/education_form_test.dart`: pengujian navigasi, validasi, isi dialog,
  nilai opsional, dan layar ponsel dengan keyboard terbuka.
- `test/test_helpers.dart`: pemuatan font Roboto dari SDK untuk widget test;
  helper sebelumnya dipakai kembali oleh tes navigasi tutorial.
- `README.md`: petunjuk menjalankan, empat jawaban refleksi, pemetaan field ke
  model, progres, checklist, dan AI disclosure.

## Batasan yang dicatat

Aturan year mengacu pada PositiveSmallIntegerField dan constraint Education,
bukan batas tahun buatan seperti hanya boleh tahun sekarang. Thumbnail tetap
opsional, dan ringkasan tetap menampilkan semua field. Fitur hanya menampilkan
dialog dan belum menyimpan data ke database, sesuai cakupan tugas.

AI memeriksa dan memperbaiki hasil implementasinya sendiri. Catatan ini tidak
mengklaim adanya perbaikan manual oleh pengguna atau pengujian ponsel fisik yang
belum dilakukan. Hasil `flutter analyze`, `flutter test`, dan status commit/push
perlu dibaca bersama laporan akhir pengerjaan.

## Hasil pemeriksaan

- `flutter analyze`: tidak menemukan masalah.
- `flutter test`: 12 tes lolos (10 tes Assignment 8 dan 2 tes alur tutorial).
- `flutter build web --no-pub`: build berhasil.
- Chrome headless: kartu membuka Education, drawer membuka Education, dan Home
  pada drawer form kembali ke halaman utama. Browser memakai profil sementara.
- Screenshot browser pada viewport 360×640 diperiksa. Pengujian keyboard terbuka
  dilakukan melalui widget test dengan simulasi inset 260 piksel.
- GitHub: repository `eleazarmalau/myportfolio_mobile` terkonfirmasi publik.
