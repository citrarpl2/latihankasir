import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  static void showAddProductDialog(BuildContext context) {
    final TextEditingController namaController = TextEditingController();
    final TextEditingController hargaController = TextEditingController();
    final TextEditingController stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final String namaProduk = namaController.text.trim();
                final double? harga =
                    double.tryParse(hargaController.text.trim());
                final int? stok = int.tryParse(stokController.text.trim());

                if (namaProduk.isNotEmpty && harga != null && stok != null) {
                  // You can access _addProduk directly here, no need to define it again.
                  await _ProdukState()._addProduk(namaProduk, harga, stok);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Harap isi semua field dengan benar.'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<ProdukPage> {
  List<dynamic> _produkList = [];

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

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

 Future<void> _addProduk(String namaProduk, double harga, int stok) async {
  try {
    // Menambahkan produk ke Supabase
    final response = await Supabase.instance.client.from('produk').insert({
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
    }).select();  // Dapatkan data yang baru saja dimasukkan

    // Menambahkan produk yang baru ke dalam daftar produk tanpa memanggil _fetchProduk
    setState(() {
  _produkList.add(response[0]);  // Menambahkan produk baru ke dalam daftar
});

  } catch (error) {
    debugPrint('Error adding produk: $error');
  }
}


  Future<void> _editProduk(
      int produkId, String namaProduk, double harga, int stok) async {
    await Supabase.instance.client.from('produk').update({
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
    }).eq('produk_id', produkId);
    _fetchProduk();
  }

  Future<void> _deleteProduk(int produkId) async {
    await Supabase.instance.client
        .from('produk')
        .delete()
        .eq('produk_id', produkId);
    _fetchProduk();
  }

  void _showEditProdukDialog(Map<String, dynamic> item) {
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
              onPressed: () async {
                final String namaproduk = namaProdukController.text;
                final double harga =
                    double.tryParse(hargaController.text) ?? 0.0;
                final int stok = int.tryParse(stokController.text) ?? 0;

                if (namaproduk.isNotEmpty && harga > 0 && stok >= 0) {
                  await _editProduk(item['produk_id'], namaproduk, harga, stok);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mohon isi data dengan benar.')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _produkList.isEmpty
        ? const Center(child: Text('Tidak ada produk.'))
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _produkList.length,
            itemBuilder: (context, index) {
              final produk = _produkList[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(produk['nama_produk']),
                  subtitle: Text(
                    'Harga: ${produk['harga']} - Stok: ${produk['stok']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF40A9FF)),
                        onPressed: () => _showEditProdukDialog(produk),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduk(produk['produk_id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}