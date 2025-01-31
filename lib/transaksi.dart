import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';
import 'main.dart';

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiState createState() => _TransaksiState();
}

class _TransaksiState extends State<TransaksiPage> {
  // Daftar produk dan produk yang dipilih tetap sama
  List<dynamic> _produkList = [];
  List<Map<String, dynamic>> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  // Ambil data produk dari Supabase
  Future<void> _fetchProduk() async {
    try {
      final response = await Supabase.instance.client.from('produk').select();
      setState(() {
        _produkList = response as List<dynamic>;
      });
    } catch (error) {
      debugPrint('Error fetching produk: $error');
    }
  }

  // Menambah produk ke daftar transaksi
  void _addProductToTransaksi(dynamic produk, int quantity) {
    setState(() {
      _selectedProducts.add({
        'produk': produk,
        'quantity': quantity,
        'total': produk['harga'] * quantity,
      });
    });
  }

  // Menghapus produk dari daftar transaksi
  void _removeProductFromTransaksi(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  // Menambah transaksi ke database
  Future<void> _addTransaksi() async {
    try {
      final totalTransaksi = _selectedProducts.fold<double>(0.0, (sum, item) {
        return sum + (item['total'] ?? 0.0); // Jika 'total' null, gunakan 0.0
      });

      final response = await Supabase.instance.client.from('transaksi').insert({
        'total': totalTransaksi,
        'tanggal': DateTime.now().toIso8601String(),
      });

      final transaksiId = response[0]['transaksi_id'];

      // Menyimpan detail produk yang dibeli
      for (var item in _selectedProducts) {
        await Supabase.instance.client.from('detail_transaksi').insert({
          'transaksi_id': transaksiId,
          'produk_id': item['produk']['produk_id'],
          'quantity': item['quantity'],
          'total': item['total'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil!')),
      );

      setState(() {
        _selectedProducts.clear(); // Mengosongkan daftar produk yang dipilih
      });
    } catch (error) {
      debugPrint('Error adding transaksi: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, coba lagi.')),
      );
    }
  }

  // Dialog untuk memilih produk dan kuantitas
  void _showAddProductDialog() {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<dynamic>(
                hint: const Text('Pilih Produk'),
                items: _produkList
                    .map((produk) => DropdownMenuItem(
                          value: produk,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(produk['nama_produk']),
                              Text('Rp ${produk['harga']}'),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (produk) {
                  if (produk != null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Masukkan Kuantitas'),
                          content: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Kuantitas'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                final quantity =
                                    int.tryParse(quantityController.text);
                                if (quantity != null && quantity > 0) {
                                  _addProductToTransaksi(produk, quantity);
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Masukkan kuantitas yang valid')),
                                  );
                                }
                              },
                              child: const Text('Tambah'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Menampilkan detail transaksi
  void _showTransaksiDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Transaksi'),
          content: SingleChildScrollView(
            child: Column(
              children: _selectedProducts.map((item) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(item['produk']['nama_produk']),
                    subtitle: Text(
                        'Kuantitas: ${item['quantity']} - Total: ${item['total']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeProductFromTransaksi(
                            _selectedProducts.indexOf(item));
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () {
                _addTransaksi();
                Navigator.of(context).pop();
              },
              child: const Text('Selesaikan Transaksi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green[600], // Warna teks tombol
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Sudut tumpul
            ),
          ),
          onPressed: _showAddProductDialog,
          child: const Text('Pilih Produk'),
        ),
        const SizedBox(height: 16), // Jarak antar tombol
        Expanded(
          child: _selectedProducts.isEmpty
              ? const Center(child: Text('Belum ada produk yang dipilih.'))
              : ListView.builder(
                  itemCount: _selectedProducts.length,
                  itemBuilder: (context, index) {
                    final item = _selectedProducts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(item['produk']['nama_produk']),
                        subtitle: Text(
                            'Jumlah Produk: ${item['quantity']} - Total: ${item['total']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeProductFromTransaksi(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16), // Jarak antar tombol
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.green, // Warna teks tombol
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Sudut tumpul
            ),
          ),
          onPressed: _selectedProducts.isEmpty ? null : _showTransaksiDetails,
          child: const Text('Selesaikan Transaksi'),
        ),
      ],
    );
  }
}