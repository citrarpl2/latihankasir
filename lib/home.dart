import 'package:flutter/material.dart';
import 'pelanggan.dart';
import 'transaksi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart'; // Import halaman LoginPage
import 'produk.dart'; // Import ProdukScreen

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.green[600], // Sesuaikan dengan warna tombol di halaman login
        title: const Text(
          'Frozen Food Alba',
          style: TextStyle(
              color: Colors.black), // Mengubah warna teks menjadi putih
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                          (route) => false,
                        );
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? const ProdukPage() : _selectedIndex == 1 
          ? TransaksiPage() : _selectedIndex == 2
          ? PelangganPage() : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.green[600], // Menyesuaikan dengan AppBar
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Pelanggan',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
               // Senada dengan tombol login
              onPressed: () {
                // Correct method call for showing the add product dialog
                ProdukPage.showAddProductDialog(context); // This should now work correctly
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}