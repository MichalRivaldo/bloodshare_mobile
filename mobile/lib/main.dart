import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/blood_request_provider.dart';
import 'providers/donation_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BloodShareApp());
}

class BloodShareApp extends StatelessWidget {
  const BloodShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BloodRequestProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
      ],
      child: MaterialApp.router(
        title: 'BloodShare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
