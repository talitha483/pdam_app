import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'views/role_view.dart';
import 'views/customer_riwayat_pembayaran_page.dart';
import 'views/customer_dashboard_view.dart';
import 'views/main_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alirin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/role': (_) => const RoleView(),
        '/customer-dashboard': (_) => const CustomerDashboardView(),
        '/admin-dashboard': (_) => const MainView(),
        '/customer-riwayat-pembayaran': (_) =>
            const CustomerRiwayatPembayaranPage(),
      },
    );
  }
}
