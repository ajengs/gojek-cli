# Go-CLI App

## Flow Utama

### Step 1 - Registrasi

Ketika pertama kali dibuka, aplikasi akan meminta pengguna memasukkan informasi:
- Nama
- Email
- Nomor HP
- Password (untuk keperluan latihan kali ini plain text saja)  
    
Setelah diinput, aplikasi akan menyimpan data-data tersebut ke dalam file `user.json`.

    Catatan: Apabila aplikasi dibuka untuk kedua kali-nya dan file `user.json` sudah ada, maka langsung ke step 2.

### Step 2 - Login

Setelah selesai input data awal, aplikasi akan menampilkan halaman login dengan input:
- Email/Nomor HP
- Password

Jika berhasil, user akan masuk ke aplikasi (masuk step 3).  
Jika gagal, aplikasi menampilkan kembali halaman login dengan pesan:
"Kombinasi Email/Nomor HP dan Password yang Anda masukkan salah".

### Step 3 - Menu Utama

Setelah berhasil login, aplikasi akan menampilkan menu:
- Lihat Profil
- Pesan Gojek
- Lihat Riwayat Transaksi

### Step 4.1 - Lihat Profil

Jika pengguna memilih menu "Lihat Profil", aplikasi akan menampilkan:
- Profil yang tersimpan pada file "user.json"
- Menu "Ubah Profil"
- Menu "Kembali ke Menu Utama"

### Step 4.1.1 - Ubah Profile

Jika memilih menu "Ubah Profil", aplikasi akan meminta pengguna memasukkan informasi:
- Nama
- Email
- Nomor HP
- Password

Field yang diisi akan berubah informasinya pada `user.json` jika pengguna memilih menu "Simpan".  
Semua perubahan akan diabaikan jika pengguna memilih menu "Batal".

### Step 4.2 - Pesan Gojek

Jika pengguna memilih menu Pesan Gojek, aplikasi akan meminta pengguna memasukkan informasi **lokasi saat ini**.

Kemudian aplikasi akan meminta pengguna memasukkan **lokasi tujuan**.

Aplikasi kemudian akan menghitung biaya yang harus dibayarkan dengan rumus: `jarak antar lokasi (float) * 1500` hanya apabila **lokasi dilayani**.

```ruby
# Daftar lokasi yang bisa diinput beserta koordinatnya masing-masing (dengan tipe data Point) tersimpan pada file "locations.json".

# Jika lokasi Asal atau Tujuan tidak ada pada daftar lokasi ketika menghitung biaya, aplikasi menampilkan pesan "Belum melayani rute tersebut".
```

Aplikasi kemudian menampilkan tampilan review pesanan dan menu:
- Menu "Pesan"
- Menu "Ulangi"
- Menu "Kembali ke Menu Utama"

Jika pengguna memilih menu `Pesan` maka aplikasi akan menyimpan data transaksi ke file `orders.json`. Data-data yang disimpan adalah sebagai berikut:
- Timestamp
- Asal
- Tujuan
- Biaya

### Step 4.3 - Lihat Riwayat Transaksi

Jika pengguna memilih menu "Lihat Riwayat Transaksi", aplikasi akan menampilkan daftar riwayat transaksi yang terdapat di file "orders.json" ke layar

## Flow Ekstra

Apabila flow utama di atas telah selesai sebelum waktu berakhir, maka peserta dapat memilih 1 atau lebih flow ekstra berikut ini sebagai nilai tambah:

1. Buatlah file `fleet_loc.json` dengan contoh isi sebagai berikut:

```ruby
[
    {
        driver: "Budi",
        coord: [1,2]
    }, 
    {
        driver: "Anna",
        coord: [-20,5]
    },
    ...dst
]
```

Gunakan file tersebut untuk menentukan seseorang akan mendapatkan go-jek atau tidak dari lokasi dia berada saat ini. Apabila jaraknya (1.0) atau kurang, maka asumsikan user mendapatkan armada tersebut, apabila tidak ada yang sesuai maka asumsikan user tidak mendapatkan go-jek sehingga perlu diberikan pilihan untuk mengulang atau kembali ke menu utama.

Pindahkan coord driver go-jek apabila order terkonfirmasi.

*(Nilai tambah: 15)*

2. User dapat memilih `gojek` atau `gocar` ketika memesan kendaraan. Perbedaan-nya adalah `gocar` tarifnya lebih mahal, yaitu `2500`. File `fleets_loc.json`juga perlu diupdate sehingga menyimpan tipe armada.

*(Catatan: perlu mengerjakan flow ekstra nomor 1)*
*(Nilai tambah: 8)*

3. Terdapat menu baru untuk melakukan top-up saldo `go-pay`. Ketika memesan kendaraan, pengguna dapat memilih melakukan pembayaran dengan uang tunai atau `go-pay`. Apabila dengan `go-pay` maka saldo akan berkurang. Lengkapi juga dengan validasi apabila saldo tidak mencukupi.

*(Nilai tambah: 5)*

4. Terdapat file `promo.json` yang berisi kode voucher. Kode voucher dapat berupa potongan harga tunai atau potongan harga persentase. User dapat diminta memasukkan kode voucher ketika memesan kendaraan untuk mendapatkan potongan harga.

*(Nilai tambah: 2)*

## Kriteria penilaian

1. Terdapat unit-test yang lengkap dan menguji karakteristik aplikasi berdasarkan spek di atas dengan baik. Unit test ketika dijalankan terhadap aplikasi tidak mengembalikan error.

2. Aplikasi dibentuk dengan prinsip OO yang baik, ditandai dengan desain kelas yang baik, memiliki karakteristik SRP dan DRY serta dapat dijelaskan dan diargumentasikan dengan baik ketika tahap demo.

3. Coding convention go-jek diterapkan dengan baik.

4. Nilai tambah:
- Mengerjakan flow ekstra
- Aplikasi mampu menangani aksi tidak terduga user
