import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pool_and_chill_app/features/auth/screens/login_screen.dart';
import 'package:pool_and_chill_app/data/api/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final apiClient = ApiClient(
    baseUrl: dotenv.env['API_BASE_URL']!,
  );

  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({
    super.key,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pool & Chill',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 62, 131, 140),
        ),
      ),
      home: LoginScreen(apiClient: apiClient),
    );
  }
}
