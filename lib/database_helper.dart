import 'dart:async'; 
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Kelas ini bertanggung jawab untuk mengelola database SQLite
class DatabaseHelper {
  // Nama database dan versinya
  static const _databaseName = "db_barang.db"; 
  static const _databaseVersion = 2; // Versi database

  // Singleton pattern untuk memastikan hanya ada satu instance DatabaseHelper
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Objek Database yang digunakan untuk operasi database
  static Database? _database;

  // Getter untuk mengakses database (akan diinisialisasi jika belum tersedia)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Fungsi untuk inisialisasi database
  Future<Database> _initDatabase() async {
    // Menentukan path lokasi database di perangkat
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate, // Memanggil fungsi _onCreate jika database belum ada
      onUpgrade: _onUpgrade, // Memanggil fungsi _onUpgrade jika versi naik
    );
  }

  // Fungsi untuk membuat tabel baru saat database pertama kali dibuat
  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Primary key untuk tabel
        image TEXT,                           -- Kolom untuk menyimpan path gambar
        name TEXT NOT NULL,                   -- Kolom untuk nama barang (wajib diisi)
        quantity INTEGER NOT NULL,            -- Kolom untuk jumlah barang (wajib diisi)
        category TEXT NOT NULL,               -- Kolom untuk kategori barang (wajib diisi)
        merk TEXT                             -- Kolom untuk merk barang (opsional)
      )
    ''');
  }

  // Fungsi untuk menangani perubahan struktur database saat versi naik
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Menambahkan kolom 'image' jika upgrade dari versi 1 ke 2
      await db.execute('ALTER TABLE barang ADD COLUMN image TEXT');
      // Menambahkan kolom 'merk' jika belum ada
      await db.execute('ALTER TABLE barang ADD COLUMN merk TEXT');
    }
  }

  // Fungsi untuk menambahkan data ke tabel barang
  Future<int> insertBarang(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('barang', row);
  }

  // Fungsi untuk mengambil semua data dari tabel barang
  Future<List<Map<String, dynamic>>> queryAllBarang() async {
    Database db = await instance.database;
    return await db.query('barang');
  }

  // Fungsi untuk memperbarui data tertentu di tabel barang
  Future<int> updateBarang(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id']; // ID barang yang akan diperbarui
    return await db.update('barang', row, where: 'id = ?', whereArgs: [id]);
  }

  // Fungsi untuk menghapus data tertentu dari tabel barang
  Future<int> deleteBarang(int id) async {
    Database db = await instance.database;
    return await db.delete('barang', where: 'id = ?', whereArgs: [id]);
  }
}
