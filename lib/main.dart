import 'dart:io';
import 'package:flutter/material.dart';
import 'add_barang_page.dart';
import 'edit_barang_page.dart';
import 'database_helper.dart';

void main() => runApp(const MyApp());
// Fungsi utama aplikasi yang menjalankan widget MyApp sebagai titik masuk.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Barang', // Judul aplikasi
      theme: ThemeData.dark(), // Mengatur tema aplikasi menjadi gelap
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug di pojok layar
      home: const MyHomePage(), // Halaman awal aplikasi
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // Controller untuk menangani input pencarian
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // FocusNode untuk mengatur fokus input pencarian

  // List untuk menyimpan data barang yang ditampilkan dan seluruh data barang
  List<Map<String, dynamic>> _barangList = [];
  List<Map<String, dynamic>> _allBarangList = [];

  // Variabel untuk menyimpan filter kategori dan merk yang dipilih
  String? _selectedCategory;
  String? _selectedMerk;

  // Daftar kategori dan merk yang tersedia
  final List<String> _categories = [
    'Oli',
    'Spare part mesin',
    'Spare part CVT',
    'Ban',
    'Lampu',
    'Shock',
    'Variasi'
  ];

  final List<String> _merks = [
    'Honda',
    'Yamaha',
    'Suzuki',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData(); // Memuat data barang saat aplikasi pertama kali dijalankan
  }

  @override
  void dispose() {
    _searchController.dispose(); // Membersihkan controller pencarian
    _searchFocusNode.dispose(); // Membersihkan FocusNode pencarian
    super.dispose();
  }

  Future<void> _fetchData() async {
    // Fungsi untuk mengambil data barang dari database
    final data = await DatabaseHelper.instance.queryAllBarang();
    setState(() {
      _barangList = data; // Menyimpan data barang yang akan ditampilkan
      _allBarangList = data; // Menyimpan salinan data asli
    });
  }

  void _clearFilters() {
    // Fungsi untuk menghapus semua filter yang diterapkan
    setState(() {
      _searchController.clear(); // Mengosongkan input pencarian
      _selectedCategory = null; // Menghapus kategori yang dipilih
      _selectedMerk = null; // Menghapus merk yang dipilih
      _barangList = List.from(_allBarangList); // Mengembalikan data barang asli
    });
    _searchFocusNode.unfocus(); // Menghapus fokus dari input pencarian
  }

  void _searchItems(String query) {
    // Fungsi untuk mencari barang berdasarkan nama
    final data = _allBarangList.where((item) {
      return item['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _barangList = data; // Menyimpan hasil pencarian
    });
  }

  void _filterItems() {
    // Fungsi untuk memfilter barang berdasarkan kategori dan merk
    setState(() {
      _barangList = _allBarangList.where((item) {
        final matchesCategory =
            _selectedCategory == null || item['category'] == _selectedCategory;
        final matchesMerk =
            _selectedMerk == null || item['merk'] == _selectedMerk;
        return matchesCategory && matchesMerk;
      }).toList();
    });
    _sortBarangByStock(); // Mengurutkan barang berdasarkan stok
  }

  void _sortBarangByStock() {
    // Fungsi untuk mengurutkan barang berdasarkan jumlah stok secara ascending
    _barangList.sort((a, b) => a['quantity'].compareTo(b['quantity']));
  }

  Future<void> _editBarang(Map<String, dynamic> barang) async {
    // Fungsi untuk mengedit data barang
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBarangPage(barang: barang), // Mengarahkan ke halaman edit
      ),
    );
    if (result == true) {
      _fetchData(); // Memuat ulang data barang jika ada perubahan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Mengatur warna latar belakang AppBar menjadi hitam
        title: const Text('Stock Barang'), // Judul AppBar
      ),
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        // Menambahkan GestureDetector untuk menghilangkan fokus input pencarian (menutup keyboard) saat pengguna mengetuk area lain di layar.
        child: RefreshIndicator(
          onRefresh: () async {
            _clearFilters(); // Menghapus filter yang diterapkan sebelumnya
            await _fetchData(); // Memuat ulang data barang
          },
          // Menambahkan fungsi refresh data saat pengguna menarik layar ke bawah.
          child: Container(
            color: Colors.black, // Mengatur warna latar belakang halaman menjadi hitam
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Memberikan padding sebesar 8 piksel di sekitar TextField untuk mencari barang.
                  child: TextField(
                    controller: _searchController, // Menghubungkan TextField dengan controller untuk input pencarian
                    focusNode: _searchFocusNode, // Menghubungkan TextField dengan FocusNode untuk mengatur fokus
                    decoration: const InputDecoration(
                      labelText: 'Cari Barang', // Label untuk input pencarian
                      labelStyle: TextStyle(color: Colors.white), // Mengatur warna label menjadi putih
                      suffixIcon: Icon(Icons.search, color: Colors.white),
                      // Menambahkan ikon pencarian di sebelah kanan TextField
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        // Mengatur warna garis bawah TextField saat tidak fokus menjadi putih
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        // Mengatur warna garis bawah TextField saat fokus menjadi putih
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    // Mengatur warna teks yang diketik di TextField menjadi putih
                    onChanged: _searchItems,
                    // Memanggil fungsi `_searchItems` setiap kali teks berubah untuk melakukan pencarian real-time
                    onSubmitted: (value) {
                      _searchFocusNode.unfocus();
                      // Menutup keyboard secara eksplisit hanya setelah pengguna menekan tombol submit (enter)
                    },
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.grey, // Menambahkan garis pemisah antara item pada ListView
                    ),
                    itemCount: _barangList.length, // Menentukan jumlah item dalam ListView
                    itemBuilder: (context, index) {
                      final barang = _barangList[index]; // Mengambil data barang pada indeks tertentu

                      // Menentukan warna stock berdasarkan jumlah kuantitas barang
                      Color stockColor;
                      if (barang['quantity'] >= 50) {
                        stockColor = Colors.green; // Warna hijau jika kuantitas >= 50
                      } else if (barang['quantity'] >= 20 && barang['quantity'] <= 49) {
                        stockColor = Colors.yellow; // Warna kuning jika kuantitas antara 20-49
                      } else {
                        stockColor = Colors.red; // Warna merah jika kuantitas < 20
                      }

                      return Dismissible(
                        key: Key(barang['id'].toString()), // Memberikan key unik untuk setiap item
                        background: Container(
                          color: const Color.fromARGB(255, 255, 246, 72), // Latar belakang untuk aksi edit (geser ke kiri)
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.edit, color: Colors.white), // Ikon edit
                        ),
                        secondaryBackground: Container(
                          color: Colors.red, // Latar belakang untuk aksi delete (geser ke kanan)
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white), // Ikon delete
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            // Jika pengguna menggeser ke kanan (hapus)
                            final confirmDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.black, // Latar belakang dialog konfirmasi
                                  title: const Text('Konfirmasi Hapus',
                                      style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus barang ini?',
                                      style: TextStyle(color: Colors.white)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Tidak',
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Ya', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmDelete == true) {
                              // Menghapus barang dari database jika pengguna menekan 'Ya'
                              await DatabaseHelper.instance.deleteBarang(barang['id']);
                              _fetchData(); // Memuat ulang data setelah penghapusan
                            }
                            return confirmDelete;
                          } else {
                            // Jika pengguna menggeser ke kiri (edit)
                            _editBarang(barang);
                            return false; // Tidak menghapus item
                          }
                        },
                        child: ListTile(
                          leading: barang['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(barang['image']),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300], // Warna latar belakang jika gambar tidak tersedia
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image, color: Colors.grey), // Ikon untuk menampilkan jika gambar tidak ada
                                ),
                          title: Text(barang['name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)), // Nama barang dengan gaya teks tebal
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Merk: ${barang['merk']}',
                                  style: const TextStyle(color: Colors.grey)), // Menampilkan merk barang
                              Text('Kategori: ${barang['category']}',
                                  style: const TextStyle(color: Colors.grey)), // Menampilkan kategori barang
                            ],
                          ),
                          trailing: Text(
                            '${barang['quantity']}',
                            style: TextStyle(
                                color: stockColor, fontSize: 16), // Menampilkan kuantitas dengan warna berdasarkan stok
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Warna latar belakang navigasi bawah
        selectedItemColor: Colors.white, // Warna ikon yang dipilih
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255), // Warna ikon yang tidak dipilih
        items: const [
          // Item untuk menambahkan barang
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Tambah',
          ),
          // Item untuk menampilkan filter
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Filter',
          ),
        ],
        onTap: (index) {
          // Menangani aksi ketika item navigasi ditekan
          if (index == 0) { // Tindakan jika item 'Tambah' dipilih
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddBarangPage()),
            ).then((_) => _fetchData()); // Kembali dari halaman AddBarangPage, memuat ulang data
          } else if (index == 1) { // Tindakan jika item 'Filter' dipilih
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.black, // Latar belakang dialog
                  title: const Text('Filter Barang', style: TextStyle(color: Colors.white)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min, // Ukuran kolom sesuai kontennya
                    children: [
                      // Dropdown untuk kategori
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        dropdownColor: Colors.black, // Warna dropdown
                      ),
                      // Dropdown untuk merk
                      DropdownButtonFormField<String>(
                        value: _selectedMerk,
                        items: _merks
                            .map((merk) => DropdownMenuItem(
                                  value: merk,
                                  child: Text(merk, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMerk = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Merk',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        dropdownColor: Colors.black, // Warna dropdown
                      ),
                    ],
                  ),
                  actions: [
                    // Tombol reset untuk membersihkan filter
                    TextButton(
                      onPressed: () {
                        _clearFilters(); // Menghapus filter yang dipilih
                        Navigator.pop(context); // Menutup dialog
                      },
                      child: const Text('Reset', style: TextStyle(color: Color.fromARGB(255, 255, 0, 0))),
                    ),
                    // Tombol untuk menerapkan filter
                    ElevatedButton(
                      onPressed: () {
                        _filterItems(); // Menjalankan fungsi filter
                        Navigator.pop(context); // Menutup dialog
                      },
                      child: const Text('Terapkan', style: TextStyle(color: Colors.green)),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
