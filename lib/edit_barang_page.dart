import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';

class EditBarangPage extends StatefulWidget {
  // Widget untuk halaman edit barang, menerima data barang yang akan diedit sebagai parameter.
  final Map<String, dynamic> barang;

  const EditBarangPage({super.key, required this.barang});

  @override
  // Membuat state untuk halaman EditBarangPage.
  // ignore: library_private_types_in_public_api
  _EditBarangPageState createState() => _EditBarangPageState();
}

class _EditBarangPageState extends State<EditBarangPage> {
  // Controller untuk input nama barang.
  final TextEditingController _nameController = TextEditingController();
  // Controller untuk input jumlah barang.
  final TextEditingController _quantityController = TextEditingController();
  // Variabel untuk menyimpan kategori yang dipilih.
  String? _categorySelected;
  // Variabel untuk menyimpan merk yang dipilih.
  String? _merkSelected;
  // Variabel untuk menyimpan file gambar.
  File? _image;

  // Daftar kategori barang.
  final List<String> _categories = [
    'Oli',
    'Spare part mesin',
    'Spare part CVT',
    'Ban',
    'Lampu',
    'Shock',
    'Variasi'
  ];

  // Daftar merk barang.
  final List<String> _merks = [
    'Honda',
    'Yamaha',
    'Suzuki',
  ];

  @override
  void initState() {
    super.initState();
    // Mengisi nilai awal field berdasarkan data barang yang diterima.
    _nameController.text = widget.barang['name'];
    _quantityController.text = widget.barang['quantity'].toString();
    _categorySelected = widget.barang['category'];
    _merkSelected = widget.barang['merk'];
    if (widget.barang['image'] != null) {
      _image = File(widget.barang['image']);
    }
  }

  // Fungsi untuk memilih gambar dari galeri.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Fungsi untuk menyimpan data barang yang telah diperbarui.
  void _saveBarang() async {
    // Validasi input, memastikan semua field terisi.
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi semua field')),
      );
      return;
    }

    // Membuat map untuk barang yang telah diperbarui.
    final updatedBarang = {
      'id': widget.barang['id'], // ID barang tetap sama.
      'name': _nameController.text, // Nama barang baru.
      'quantity': int.tryParse(_quantityController.text), // Jumlah barang baru.
      'category': _categorySelected, // Kategori baru.
      'merk': _merkSelected, // Merk baru.
      'image': _image?.path // Path gambar baru (jika ada).
    };

    // Memperbarui data barang di database.
    await DatabaseHelper.instance.updateBarang(updatedBarang);
    // Menutup halaman dan mengembalikan status sukses.
    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Menghindari overflow layout saat keyboard muncul.
      appBar: AppBar(
        backgroundColor: Colors.black, // Mengatur warna latar belakang AppBar.
        title: const Text('Edit Barang'), // Menampilkan judul halaman.
      ),
      body: SingleChildScrollView(
        // Memungkinkan halaman untuk di-scroll jika konten melebihi layar.
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Menambahkan padding di sekitar konten.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Menyusun konten ke arah kiri.
            children: [
              GestureDetector(
                onTap: _pickImage, // Menentukan aksi untuk memilih gambar saat diklik.
                child: Container(
                  height: 300, // Tinggi container untuk area gambar.
                  width: double.infinity, // Lebar container sesuai layar.
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), // Menambahkan border abu-abu.
                    borderRadius: BorderRadius.circular(8), // Membuat sudut border melengkung.
                  ),
                  child: _image != null
                      ? InteractiveViewer(
                          // Menampilkan gambar jika ada, dapat di-zoom dan digerakkan.
                          child: Image.file(_image!, fit: BoxFit.contain),
                        )
                      : const Center(
                          // Menampilkan teks 'Pilih Gambar' jika belum ada gambar.
                          child: Text(
                            'Pilih Gambar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16), // Memberikan jarak antar elemen.
              TextField(
                controller: _nameController, // Input untuk nama barang.
                decoration: const InputDecoration(
                  labelText: 'Nama Barang', // Label untuk input nama barang.
                  labelStyle: TextStyle(color: Colors.white), // Warna label putih.
                  enabledBorder: UnderlineInputBorder(
                    // Border bawah saat input tidak fokus.
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    // Border bawah saat input fokus.
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white), // Warna teks input putih.
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController, // Input untuk kuantitas barang.
                decoration: const InputDecoration(
                  labelText: 'Kuantitas', // Label untuk input kuantitas barang.
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number, // Jenis input angka.
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // Dropdown untuk memilih kategori.
                value: _categorySelected, // Nilai awal dropdown.
                items: _categories.map((category) {
                  // Membuat daftar item dropdown berdasarkan kategori.
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Kategori', // Label dropdown.
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownColor: Colors.black, // Warna latar dropdown.
                onChanged: (value) => setState(() => _categorySelected = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // Dropdown untuk memilih merk.
                value: _merkSelected, // Nilai awal dropdown.
                items: _merks.map((merk) {
                  // Membuat daftar item dropdown berdasarkan merk.
                  return DropdownMenuItem(
                    value: merk,
                    child: Text(merk, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Merk', // Label dropdown.
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                dropdownColor: Colors.black,
                onChanged: (value) => setState(() => _merkSelected = value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                // Tombol untuk menyimpan data barang yang telah diedit.
                onPressed: _saveBarang, // Memanggil fungsi untuk menyimpan barang.
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Warna tombol hijau.
                  minimumSize: const Size(double.infinity, 50), // Lebar penuh dan tinggi 50.
                ),
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16), // Jarak untuk mencegah konten tertutup.
            ],
          ),
        ),
      ),
    );
  }
}
