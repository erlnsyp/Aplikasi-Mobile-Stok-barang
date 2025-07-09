// Import library yang dibutuhkan
import 'dart:io'; // Untuk mengelola file
import 'package:flutter/material.dart'; // Library untuk UI Flutter
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar dari galeri atau kamera
import 'database_helper.dart'; // File helper untuk operasi database

// Kelas untuk halaman menambah barang
class AddBarangPage extends StatefulWidget {
  const AddBarangPage({super.key}); // Constructor halaman

  @override
  // ignore: library_private_types_in_public_api
  _AddBarangPageState createState() => _AddBarangPageState(); // Membuat state untuk widget ini
}

// State dari halaman menambah barang
class _AddBarangPageState extends State<AddBarangPage> {
  // Controller untuk input teks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String? _categorySelected; // Variabel untuk menyimpan kategori yang dipilih
  String? _merkSelected; // Variabel untuk menyimpan merk yang dipilih
  File? _image; // Variabel untuk menyimpan file gambar

  // Daftar kategori untuk dropdown
  final List<String> _categories = [
    'Oli',
    'Spare part mesin',
    'Spare part CVT',
    'Ban',
    'Lampu',
    'Shock',
    'Variasi'
  ];
  
  // Daftar merk untuk dropdown
  final List<String> _merks = [
    'Honda',
    'Yamaha',
    'Suzuki',
  ];

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker(); // Objek untuk mengambil gambar
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Memilih gambar dari galeri
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Menyimpan gambar yang dipilih ke variabel
      });
    }
  }

  // Fungsi untuk menambahkan barang ke database
  Future<void> _addBarang() async {
    // Mengecek apakah semua input sudah diisi
    if (_nameController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _categorySelected != null &&
        _merkSelected != null &&
        _image != null) {
      // Memasukkan data barang ke database
      await DatabaseHelper.instance.insertBarang({
        'name': _nameController.text, // Nama barang
        'quantity': int.parse(_quantityController.text), // Kuantitas barang
        'category': _categorySelected, // Kategori barang
        'merk': _merkSelected, // Merk barang
        'image': _image!.path, // Path gambar barang
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Kembali ke halaman utama setelah data tersimpan
    } else {
      // Menampilkan pesan error jika ada input yang kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Menghindari overflow saat keyboard muncul
      appBar: AppBar(
        backgroundColor: Colors.black, // Warna latar belakang AppBar diatur ke hitam
        title: const Text('Tambah Barang'), // Judul AppBar
      ),
      body: SingleChildScrollView( // Membungkus konten agar dapat di-scroll
        padding: const EdgeInsets.all(16.0), // Menambahkan padding ke semua sisi
        child: Column( // Kolom untuk menampung semua widget
          crossAxisAlignment: CrossAxisAlignment.start, // Menyejajarkan konten ke kiri
          children: [
            GestureDetector( // Widget untuk mendeteksi tap pada area gambar
              onTap: _pickImage, // Fungsi untuk memilih gambar
              child: Container(
                height: 250, // Tinggi kotak gambar
                width: double.infinity, // Lebar mengikuti layar
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Memberikan border abu-abu
                  borderRadius: BorderRadius.circular(8), // Membuat sudut membulat
                ),
                child: _image != null
                    ? InteractiveViewer( // Jika gambar ada, tambahkan fitur zoom
                        child: Image.file(_image!, fit: BoxFit.contain), // Menampilkan gambar
                      )
                    : const Center(child: Text('Klik untuk memilih gambar')), // Placeholder jika belum ada gambar
              ),
            ),
            const SizedBox(height: 16), // Spasi antar elemen
            TextField( // Input teks untuk nama barang
              controller: _nameController, // Menghubungkan dengan controller nama
              decoration: InputDecoration(
                labelText: 'Nama Barang', // Label input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Membuat sudut membulat
                ),
              ),
            ),
            const SizedBox(height: 16), // Spasi antar elemen
            TextField( // Input teks untuk kuantitas barang
              controller: _quantityController, // Menghubungkan dengan controller kuantitas
              decoration: InputDecoration(
                labelText: 'Kuantitas', // Label input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Membuat sudut membulat
                ),
              ),
              keyboardType: TextInputType.number, // Jenis input angka
            ),
            const SizedBox(height: 16), // Spasi antar elemen
            DropdownButtonFormField<String>( // Dropdown untuk memilih kategori
              value: _categorySelected, // Nilai yang dipilih
              items: _categories.map((category) { // Membuat daftar pilihan kategori
                return DropdownMenuItem(
                  value: category, // Nilai kategori
                  child: Text(category), // Teks kategori
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Kategori', // Label dropdown
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Membuat sudut membulat
                ),
              ),
              onChanged: (value) => setState(() => _categorySelected = value), // Perbarui nilai kategori saat dipilih
            ),
            const SizedBox(height: 16), // Spasi antar elemen
            DropdownButtonFormField<String>( // Dropdown untuk memilih merk
              value: _merkSelected, // Nilai yang dipilih
              items: _merks.map((merk) { // Membuat daftar pilihan merk
                return DropdownMenuItem(
                  value: merk, // Nilai merk
                  child: Text(merk), // Teks merk
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Merk', // Label dropdown
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Membuat sudut membulat
                ),
              ),
              onChanged: (value) => setState(() => _merkSelected = value), // Perbarui nilai merk saat dipilih
            ),
            const SizedBox(height: 16), // Spasi antar elemen
            ElevatedButton( // Tombol untuk menyimpan data barang
              onPressed: _addBarang, // Fungsi untuk menambah barang ke database
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Ukuran tombol mengikuti lebar layar
                backgroundColor: Colors.green, // Warna tombol hijau
              ),
              child: const Text('Tambah Barang'), // Teks pada tombol
            ),
            const SizedBox(height: 16), // Tambahkan padding bawah untuk ruang tambahan
          ],
        ),
      ),
    );
  }
}
