# Assignment 6

### Progres:

Commit 1: Add colors just for the vibes

Yang dikerjakan:

- Kerjaan sebelumnya sudah dikerjain di tutorial jadi buat tugas tinggal ganti color buat buttonnya 

## Questions

### 1. Explain what a widget tree is in Flutter and how parent-child relationships work between widgets.

Widget tree adalah susunan widget yang bersifat hierarki dan membentuk tampilan aplikai Flutter. Widget yang membungkus widget lain disebut parent. Widget yang ada dalam widget lain disebut child. Parent mengatur penempatan dan memberikan batasan ukuran kepada child, lalu child menentukan ukurannya sesuai batasan yang udah dibuat tadi. Widget seperti padding menerima satu widget melalui properti child, sedangkan row dan column menerima beberapa widget melalui children


### 2. List all the widgets you used in this project and explain each of their functions.

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

### 3. What is the purpose of the MaterialApp widget? Explain why this widget is commonly used as the root widget in Flutter applications.

MaterialApp menyediakan konfigurasi tingkat aplikasi untuk antarmuka berbasis Material Design, seperti tema, navigasi, dan lokalisasi. Widget ini biasanya dipasang di dekat root widget tree agar halaman-halaman di bawahnya memperoleh konfigurasi yang konsisten tanpa harus mengatur yang lain satu per satu.

### 4. Explain the difference between StatelessWidget and StatefulWidget. When should you choose StatelessWidget, and when is StatefulWidget necessary?

StatelessWidget digunakan ketika widget tidak perlu menyimpan state internal yang dapat berubah. Tampilannya ditentukan oleh konfigurasi dari parent dan data yang diperoleh melalui context. Widget ini tetap dapat dibangun ulang ketika parent memberikan konfigurasi baru atau data warisan seperti berubahnya tema. Jadi, stateless bukan berarti tampilannya tidak bisa berubah sama sekali.

Sementara itu, StatefulWdiget digunakan ketika widget perlu menyimpan state yang berubah selama pengguna berinteraksi, misalnya nilai counter, status pilihan, atau status pemuatan data. Objek widget-nya tetap immutable, sedangkan state yang berubah disimpan dalam objek State terpisah. Pemanggilan setState() memberi tahu Flutter kalau perubahan state perlu ditampilkan dengan menjalankan proses build kembali.

### 5. What is BuildContext and why is it crucial in Flutter? How is it used inside the build method?

BuildContext adalah objek yang mewakili lokasi sebuah widget dalam widget tree. Context penting karena Flutter menggunakannya untuk mencari data atau layanan dari ancestor, yaitu widget yang berada di atas lokasi tersebut. Karena itu, context yang dipakai harus berada di bawah penyedia data atau layanan yang ingin diakses.

Pada metode Widget build(BuildContext context), Flutter memberikan context milik widget yang sedang dibangun. Metode tersebut kemudian mengembalikan susunan widget untuk tampilannya. Contoh pemakaiannya dalam proyek ini:

- Theme.of(context).colorScheme.primary di MyHomePage mengambil warna utama dari tema aplikasi untuk AppBar.
- MediaQuery.of(context).size.width / 3.5 di InfoCard menghitung lebar kartu berdasarkan lebar layar.
- ScaffoldMessenger.of(context) di callback onTap milik ItemCard mencari pengelola notifikasi untuk menyembunyikan SnackBar sebelumnya dan menampilkan pesan baru.

Context milik suatu metode build() tidak sama dengan context milik child yang dikembalikannya. Misalnya, ketika build() membuat widget penyedia tema baru, context milik metode itu sendiri belum berada di bawah penyedia tema baru tersebut.

### 6. Explain the concept of hot reload in Flutter and how it differs from hot restart. When can you not rely on hot reload and must instead perform a hot restart or full restart?

Hot reload memasukkan perubahan kode Dart ke aplikasi yang sedang berjalan dan membangun ulang widget tree sambil mempertahankan state. Fitur ini cocok untuk mencoba perubahan tampilan seperti teks, padding, atau warna yang diterapkan saat build. Hot reload tidak menjalankan ulang main() dan initState().

Hot restart menjalankan ulang aplikasi Flutter dari main() dan menghapus state dalam memori. Fitur ini berguna saat perubahan perlu mengulang proses inisialisasi. Full restart menghentikan lalu menjalankan kembali aplikasi, termasuk membangun ulang kode native bila diperlukan.

Hot reload tidak cukup dalam kondisi berikut:

- Perubahan pada main() atau initState(): gunakan hot restart agar kode inisialisasi dijalankan ulang.
- Perubahan nilai awal variabel global atau field static yang sudah diinisialisasi: gunakan hot restart karena nilai tersebut dipertahankan sebagai state saat hot reload.
- Perubahan struktur tipe yang tidak didukung hot reload: misalnya mengubah enum menjadi class atau mengubah jumlah parameter generic; gunakan hot restart.
- Perubahan kode native atau konfigurasi build platform: misalnya kode Kotlin/Java di Android atau Swift/Objective-C di iOS; lakukan full restart agar perubahan dibangun ulang.

Jika hot reload gagal karena kesalahan sintaks, kesalahan tersebut perlu diperbaiki terlebih dahulu; restart tidak memperbaiki kode yang tidak bisa dikompilasi. 