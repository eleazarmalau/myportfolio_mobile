# MyPortfolio Mobile

Aplikasi portofolio Flutter untuk PBP. Tutorial 09 menyediakan form Add Project;
Assignment 8 menambahkan form **Add Education** dengan navigasi, validasi, dan
dialog ringkasan. Data pada tugas ini hanya ditampilkan dalam dialog.

## Menjalankan proyek

Lingkungan pengerjaan: Flutter 3.47.9 dan Dart 3.13.7. Proyek menggunakan
`material_ui` sesuai catatan import pada Tutorial 09.

```sh
flutter pub get
flutter run -d chrome
```

Untuk perangkat Android/iOS yang sudah dikonfigurasi, jalankan `flutter devices`,
kemudian `flutter run -d <device-id>`.

```sh
flutter analyze
flutter test
```

Struktur utama:

```text
lib/
  main.dart
  screens/
    menu.dart
    project_form.dart
    education_form.dart
  widgets/
    left_drawer.dart
    project_card.dart
```

Jawaban dari tugas sebelumnya dipertahankan di bawah ini.

## Assignment 7

### Progres:

Commit 1: Add colors just for the vibes

Yang dikerjakan:

- Kerjaan sebelumnya sudah dikerjain di tutorial jadi buat tugas tinggal ganti color buat buttonnya 

### Questions

#### 1. Explain what a widget tree is in Flutter and how parent-child relationships work between widgets.

Widget tree adalah susunan widget yang bersifat hierarki dan membentuk tampilan aplikai Flutter. Widget yang membungkus widget lain disebut parent. Widget yang ada dalam widget lain disebut child. Parent mengatur penempatan dan memberikan batasan ukuran kepada child, lalu child menentukan ukurannya sesuai batasan yang udah dibuat tadi. Widget seperti padding menerima satu widget melalui properti child, sedangkan row dan column menerima beberapa widget melalui children


#### 2. List all the widgets you used in this project and explain each of their functions.

Berikut widget yang dibuat atau dipakai secara langsung di kode ini

| Widget | Fungsi dalam proyek |
| --- | --- |
| `MyApp` | Widget utama yang diberikan kepada `runApp()` dan membangun `MaterialApp`. |
| `MaterialApp` | Mengatur judul aplikasi, tema Material, dan halaman awal aplikasi. |
| `MyHomePage` | Menyusun halaman utama yang berisi identitas, sapaan, dan menu aksi. |
| `Scaffold` | Menyediakan struktur halaman, termasuk bagian `appBar` dan `body`. |
| `AppBar` | Menampilkan bilah atas dengan judul MyPortfolio dan warna utama tema. |
| `Text` | Menampilkan judul, identitas, sapaan, nama menu, dan pesan notifikasi. |
| `Padding` | Memberikan ruang di sekitar child, misalnya pada isi halaman dan teks sapaan. |
| `Column` | Menyusun widget secara vertikal, misalnya isi halaman dan isi kartu. |
| `Row` | Menyusun tiga kartu identitas secara horizontal. |
| `SizedBox` | Memberikan jarak vertikal antarbagian halaman dan antarteks dalam kartu identitas. |
| `Center` | Memposisikan child di tengah ruang yang tersedia. |
| `GridView.count` | Menampilkan menu dalam tiga kolom, dengan jarak antaritem dan `shrinkWrap: true` agar tinggi grid menyesuaikan isinya. |
| `InfoCard` | Widget buatan sendiri untuk menampilkan pasangan judul dan isi identitas. |
| `Card` | Memberikan tampilan kartu dengan elevasi pada setiap `InfoCard`. |
| `Container` | Mengatur ukuran dan padding isi kartu identitas maupun menu. |
| `ItemCard` | Widget buatan sendiri yang menampilkan ikon, nama, warna, dan respons ketika menu ditekan. |
| `Material` | Menyediakan permukaan berwarna dan sudut membulat pada menu, sekaligus tempat efek tinta dari `InkWell`. |
| `InkWell` | Mendeteksi ketukan pada menu dan memberikan efek ripple. |
| `Icon` | Menampilkan ikon folder, tambah proyek, dan logout. |
| `SnackBar` | Menampilkan pesan sementara yang menyebutkan tombol yang ditekan. |

Selain itu, kode mengakses widget pendukung melalui `Theme.of(context)` untuk membaca tema, `MediaQuery.of(context)` untuk membaca ukuran layar, dan `ScaffoldMessenger.of(context)` untuk mengatur `SnackBar`. Widget pendukung tersebut tersedia dari susunan widget framework di atas halaman.

`ItemHomepage` adalah kelas model data untuk menyimpan nama, ikon, dan warna menu, bukan widget. `ThemeData`, `ColorScheme`, `TextStyle`, `EdgeInsets`, dan `BorderRadius` juga merupakan objek konfigurasi, bukan widget.

#### 3. What is the purpose of the MaterialApp widget? Explain why this widget is commonly used as the root widget in Flutter applications.

MaterialApp menyediakan konfigurasi tingkat aplikasi untuk antarmuka berbasis Material Design, seperti tema, navigasi, dan lokalisasi. Widget ini biasanya dipasang di dekat root widget tree agar halaman-halaman di bawahnya memperoleh konfigurasi yang konsisten tanpa harus mengatur yang lain satu per satu.

#### 4. Explain the difference between StatelessWidget and StatefulWidget. When should you choose StatelessWidget, and when is StatefulWidget necessary?

StatelessWidget digunakan ketika widget tidak perlu menyimpan state internal yang dapat berubah. Tampilannya ditentukan oleh konfigurasi dari parent dan data yang diperoleh melalui context. Widget ini tetap dapat dibangun ulang ketika parent memberikan konfigurasi baru atau data warisan seperti berubahnya tema. Jadi, stateless bukan berarti tampilannya tidak bisa berubah sama sekali.

Sementara itu, StatefulWdiget digunakan ketika widget perlu menyimpan state yang berubah selama pengguna berinteraksi, misalnya nilai counter, status pilihan, atau status pemuatan data. Objek widget-nya tetap immutable, sedangkan state yang berubah disimpan dalam objek State terpisah. Pemanggilan setState() memberi tahu Flutter kalau perubahan state perlu ditampilkan dengan menjalankan proses build kembali.

#### 5. What is BuildContext and why is it crucial in Flutter? How is it used inside the build method?

BuildContext adalah objek yang mewakili lokasi sebuah widget dalam widget tree. Context penting karena Flutter menggunakannya untuk mencari data atau layanan dari ancestor, yaitu widget yang berada di atas lokasi tersebut. Karena itu, context yang dipakai harus berada di bawah penyedia data atau layanan yang ingin diakses.

Pada metode Widget build(BuildContext context), Flutter memberikan context milik widget yang sedang dibangun. Metode tersebut kemudian mengembalikan susunan widget untuk tampilannya. Contoh pemakaiannya dalam proyek ini:

- Theme.of(context).colorScheme.primary di MyHomePage mengambil warna utama dari tema aplikasi untuk AppBar.
- MediaQuery.of(context).size.width / 3.5 di InfoCard menghitung lebar kartu berdasarkan lebar layar.
- ScaffoldMessenger.of(context) di callback onTap milik ItemCard mencari pengelola notifikasi untuk menyembunyikan SnackBar sebelumnya dan menampilkan pesan baru.

Context milik suatu metode build() tidak sama dengan context milik child yang dikembalikannya. Misalnya, ketika build() membuat widget penyedia tema baru, context milik metode itu sendiri belum berada di bawah penyedia tema baru tersebut.

#### 6. Explain the concept of hot reload in Flutter and how it differs from hot restart. When can you not rely on hot reload and must instead perform a hot restart or full restart?

Hot reload memasukkan perubahan kode Dart ke aplikasi yang sedang berjalan dan membangun ulang widget tree sambil mempertahankan state. Fitur ini cocok untuk mencoba perubahan tampilan seperti teks, padding, atau warna yang diterapkan saat build. Hot reload tidak menjalankan ulang main() dan initState().

Hot restart menjalankan ulang aplikasi Flutter dari main() dan menghapus state dalam memori. Fitur ini berguna saat perubahan perlu mengulang proses inisialisasi. Full restart menghentikan lalu menjalankan kembali aplikasi, termasuk membangun ulang kode native bila diperlukan.

Hot reload tidak cukup dalam kondisi berikut:

- Perubahan pada main() atau initState(): gunakan hot restart agar kode inisialisasi dijalankan ulang.
- Perubahan nilai awal variabel global atau field static yang sudah diinisialisasi: gunakan hot restart karena nilai tersebut dipertahankan sebagai state saat hot reload.
- Perubahan struktur tipe yang tidak didukung hot reload: misalnya mengubah enum menjadi class atau mengubah jumlah parameter generic; gunakan hot restart.
- Perubahan kode native atau konfigurasi build platform: misalnya kode Kotlin/Java di Android atau Swift/Objective-C di iOS; lakukan full restart agar perubahan dibangun ulang.

Jika hot reload gagal karena kesalahan sintaks, kesalahan tersebut perlu diperbaiki terlebih dahulu; restart tidak memperbaiki kode yang tidak bisa dikompilasi.

## Assignment 8

### Questions 

#### 1. Explain the differences between Navigator.push(), Navigator.pushReplacement(), and Navigator.pop(). Which method opens the form from the action card? Explain how the Home option in the drawer takes the user back to the home screen.

Navigator.push() menambahkan elemen ke atas stack navigasi sehingga halaman sebelumnya masih tersedia. Navigator.pushReplacement() mengganti halaman teratas, sehingga halaman yang diganti tidak menjadi tujuan Back berikutnya. Navigator.pop() menutup route teratasnya dan kemudian menampilkan route sebelumnya. Action card Add Project dan Add Education menggunakan Navigator.push() untuk membuka ProjectFormPage dan EducationFormPage melalui MaterialPageRoute. Dengan demikian, halaman Home tetap berada di bawah halaman form. Sementara itu, opsi Home pada drawer di left_drawer.dart menggunakan Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => MyHomePage()),);
Ketika dipilih, halaman aktif diganti dengan instance baru MyHomePage. Jadi, pengguna kembali melihat Home karena aplikasi membuat halaman Home baru, bukan melakukan pop() ke Home sebelumnya. Jika form awalnya dibuka dari action card, Home yang lama tetap berada di bawahnya dalam tumpukan navigasi.

#### 2. How does the arrangement of Scaffold, AppBar, and Drawer keep the page structure consistent? Give one example of the portfolio theme colors being used on more than one page.

Konsistensi Scaffold, AppBar, Drawer, dan tema.
Scaffold menyediakan kerangka halaman, AppBar menampilkan judul, dan Drawer menyediakan navigasi yang sama pada Home, Add Project, dan Add Education. Ketiganya memakai komponen LeftDrawer yang sama, sehingga opsi Home dan Add Project tetap tersedia bersama opsi baru Add Education. Warna Theme.of(context).colorScheme.primary dipakai pada AppBar Home dan Add Education, serta tombol Save Education. Skema warna tersebut berasal dari seed indigo di main.dart; teks dan ikon AppBar berwarna putih.

#### 3. Why was this layout chosen for the form? Explain what the spacing and scrolling widgets do when screen space is limited.

Form menggunakan Column agar field berurutan dari judul pendidikan hingga tahun selesai. Padding memberi jarak 16 piksel di tepi isi dan antarfield; Align menempatkan tombol Save di tengah. SingleChildScrollView membuat seluruh field dan tombol Save tetap dapat dijangkau ketika tinggi layar terbatas. Saat keyboard terbuka, Scaffold menyesuaikan ruang body dan form dapat digulir di ruang yang tersisa. SafeArea menjaga isi dari area sistem. Home juga dibuat dapat digulir agar penambahan kartu Education tetap dapat diakses pada layar ponsel.

#### 4.What roles do GlobalKey<FormState>, validator, and validate() play when Save is pressed? Give one example of a value the form rejects and explain why choosing an input widget or keyboard type alone is insufficient.

GlobalKey<FormState> dipasang pada Form agar tombol Save dapat mengakses statusnya. Setiap validator mengembalikan pesan kesalahan atau null jika nilainya valid. _formKey.currentState!.validate() menjalankan semua validator dan menampilkan pesan di field yang bermasalah. Dialog baru ditampilkan jika hasilnya true. Misalnya, nama institusi yang hanya berisi spasi ditolak setelah trim(), dan tahun selesai 2024 ditolak jika tahun mulai 2025. TextInputType.number hanya memilih jenis keyboard; nilai dari paste atau keyboard fisik masih dapat berupa 2025.5 atau abc, sehingga parsing dan validasi tetap diperlukan. Keyboard URL juga tidak menjamin sebuah URL memiliki skema HTTP/HTTPS dan host yang valid.

#### Progres Assignment 8

- Memeriksa checklist PDF dan model Education yang sudah ada.
- Menambahkan EducationFormPage dengan tujuh input, validasi, dan ringkasan.
- Menghubungkan kartu dan drawer serta menyesuaikan scrolling Home untuk layar
  sempit.
- Menambahkan tes perilaku form dan navigasi, lalu melengkapi dokumentasi.
- Menjalankan analisis, 12 tes otomatis, build web, dan pemeriksaan navigasi
  di Chrome headless; tampilan form juga diperiksa pada viewport ponsel.

#### AI disclosure

**Tool:** OpenAI Codex. AI membantu membaca PDF tugas, meninjau model Education
di proyek Django, menulis form Flutter, menambahkan navigasi, menyesuaikan layout
untuk layar sempit, membuat dan menjalankan tes, serta menyusun bagian Assignment
8 pada README ini.

**Strategi prompt:** persyaratan diberikan melalui PDF, disertai permintaan untuk
mengerjakan bagian “This Assignment’s Target” sesuai checklist. Konteks sebelumnya
juga menekankan agar perubahan mengikuti Tutorial 09. Karena itu, implementasi
menggunakan pola navigasi tutorial dan field Education yang benar-benar tersedia,
bukan membuat field model baru berdasarkan dugaan.

**Batasan dan evaluasi:** bantuan AI pada tutorial sebelumnya sempat menambahkan
perubahan yang tidak ada pada contoh, lalu dikoreksi setelah PDF dibandingkan
langsung. Pada tugas ini, sumber aturan field diperiksa dari model dan serializer.
Jenis keyboard tidak diperlakukan sebagai pengganti validator. Tes widget memakai
font Roboto dari SDK agar ukuran teks mendekati aplikasi, karena font Ahem bawaan
tes lebih lebar. Tes otomatis tidak menggantikan pemeriksaan pada semua perangkat.
Tidak ada klaim bahwa pengguna telah melakukan perbaikan manual atau pengujian
ponsel fisik yang belum tercatat.

Riwayat prompt dan bantuan yang relevan dicatat di
[log AI Assignment 8](docs/assignment-8-ai-log.md).
