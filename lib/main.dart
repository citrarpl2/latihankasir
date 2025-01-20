import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'home.dart'; // Pastikan halaman HomePage diimpor


Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ooqorlznonrnkipnnciq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vcW9ybHpub25ybmtpcG5uY2lxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzU5NTcsImV4cCI6MjA1MTcxMTk1N30.Pqakl-CEu9ISHbxs9CKgPJe-ubJUFNCba9cKPEdnTNU',
  );
  runApp(MyApp());
}
        
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      home: Login(), // Panggil halaman login
    );
  }
}