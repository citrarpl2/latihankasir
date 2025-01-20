import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> product = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Fungsi untuk mengambil data produk dari Supabase
  Future<void> _fetchProducts() async {
    try {
      final List<dynamic> response = await supabase.from('produk').select();
      setState(() {
        product = response.map((e) => Map<String, dynamic>.from(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      _showError('Gagal mengambil data: $e');
    }
  }

  // Fungsi untuk menambah produk
  Future<void> _addProduct(String namaProduk, double harga, int stok) async {
    try {
      final response = await supabase.from('produk').insert({
        'nama_produk': namaProduk,
        'harga': harga,
        'stok': stok,
      }).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          product.add(Map<String, dynamic>.from(response.first));
        });
      }
    } catch (e) {
      _showError('Gagal menambahkan produk: $e');
    }
  }

  // Fungsi untuk mengedit produk
  Future<void> _editProduct(int id, String namaProduk, double harga, int stok) async {
    try {
      final response = await supabase.from('produk').update({
        'nama_produk': namaProduk,
        'harga': harga,
        'stok': stok,
      }).eq('produk_id', id).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          final index = product.indexWhere((item) => item['produk_id'] == id);
          if (index != -1) {
            product[index] = Map<String, dynamic>.from(response.first);
          }
        });
      }
    } catch (e) {
      _showError('Gagal mengedit produk: $e');
    }
  }

  // Fungsi untuk menghapus produk
  Future<void> _deleteProduct(int id) async {
    try {
      await supabase.from('produk').delete().eq('produk_id', id);
      setState(() {
        product.removeWhere((item) => item['produk_id'] == id);
      });
    } catch (e) {
      _showError('Gagal menghapus produk: $e');
    }
  }

  // Fungsi untuk menampilkan error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Dialog tambah produk
  void _showAddProductDialog() {
    final TextEditingController namaProdukController = TextEditingController();
    final TextEditingController hargaController = TextEditingController();
    final TextEditingController stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaProdukController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final String namaProduk = namaProdukController.text;
                final double harga = double.tryParse(hargaController.text) ?? 0.0;
                final int stok = int.tryParse(stokController.text) ?? 0;

                if (namaProduk.isNotEmpty && harga > 0 && stok >= 0) {
                  _addProduct(namaProduk, harga, stok);
                  Navigator.of(context).pop();
                } else {
                  _showError('Mohon isi data dengan benar.');
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  // Dialog edit produk
  void _showEditProductDialog(Map<String, dynamic> item) {
    final TextEditingController namaProdukController =
        TextEditingController(text: item['nama_produk']);
    final TextEditingController hargaController =
        TextEditingController(text: item['harga'].toString());
    final TextEditingController stokController =
        TextEditingController(text: item['stok'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaProdukController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
              ),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final String namaProduk = namaProdukController.text;
                final double harga = double.tryParse(hargaController.text) ?? 0.0;
                final int stok = int.tryParse(stokController.text) ?? 0;

                if (namaProduk.isNotEmpty && harga > 0 && stok >= 0) {
                  _editProduct(item['produk_id'], namaProduk, harga, stok);
                  Navigator.of(context).pop();
                } else {
                  _showError('Mohon isi data dengan benar.');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Halaman daftar produk
  Widget _buildProductPage() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: product.length,
            itemBuilder: (context, index) {
              final item = product[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(item['nama_produk']),
                  subtitle: Text('Harga: Rp ${item['harga']}\nStok: ${item['stok']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditProductDialog(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(item['produk_id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // Halaman transaksi (placeholder)
  Widget _buildTransactionPage() {
    return const Center(
      child: Text('Halaman Transaksi Kosong!'),
    );
  }

  // Halaman akun (placeholder)
  Widget _buildAccountPage() {
    return const Center(
      child: Text('Halaman Akun Kosong!'),
    );
  }

  // Halaman-halaman dalam aplikasi
  List<Widget> get _pages => <Widget>[
        _buildProductPage(),
        _buildTransactionPage(),
        _buildAccountPage(),
      ];

  // Fungsi untuk mengubah halaman
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frozen Food Alba'),
        backgroundColor: Colors.green[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[600],
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
