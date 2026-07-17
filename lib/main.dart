import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'services/invoice_provider.dart';
import 'services/notification_service.dart';
import 'services/settings_provider.dart';
import 'services/customer_provider.dart';
import 'services/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Notification Service
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InvoiceProvider()..loadInvoices()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const InvoicelyApp(),
    ),
  );
}

class InvoicelyApp extends StatelessWidget {
  const InvoicelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return MaterialApp(
      title: 'Invoicely',
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D3B8E),
          primary: const Color(0xFF3D3B8E),
          secondary: const Color(0xFFE25E31),
          surface: Colors.white,
          onSurface: const Color(0xFF2A2859),
          onSurfaceVariant: const Color(0xFF6C699E),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F2FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF2A2859)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D3B8E),
          brightness: Brightness.dark,
          primary: const Color(0xFF6B68D1),
          secondary: const Color(0xFFFF8B66),
          surface: const Color(0xFF1E1C3D),
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFFB4B0FF),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0E21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
