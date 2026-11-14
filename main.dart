import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/daftar_database.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar_DZ');
  await DaftarDatabase.instance.database;
  runApp(const DaftarApp());
}

class DaftarApp extends StatelessWidget {
  const DaftarApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF17365D);
    const blue = Color(0xFF2463A6);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DAFTAR | دفتر',
      locale: const Locale('ar', 'DZ'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: blue, primary: blue),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE3E9F1)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7E0EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7E0EB)),
          ),
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const DashboardScreen(),
    );
  }
}
