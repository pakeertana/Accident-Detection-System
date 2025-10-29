import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http; // ✅ Added for backend request
import '../constants.dart';

class DashboardPage extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;
  bool _isOn = false;
  bool _isLoading = false; // ✅ To show loading state

  // 🧠 Replace this with your laptop's local IP (shown when you run Flask)
  final String backendUrl = "http://172.20.10.2:5000/start_accident_detection";

  void _toggleSwitch() async {
    if (_isLoading) return; // Prevent double taps

    setState(() {
      _isLoading = true;
    });

    if (!_isOn) {
      // 🔥 Turn ON → Start detection by calling backend
      try {
        final response = await http.post(Uri.parse(backendUrl));

        if (response.statusCode == 200) {
          setState(() {
            _isOn = true;
          });
          _showSnackBar("✅ Accident detection started successfully!");
        } else {
          _showSnackBar("⚠ Failed to start detection (${response.statusCode})");
        }
      } catch (e) {
        _showSnackBar("❌ Error connecting to backend: $e");
      }
    } else {
      // ⏸ Turn OFF → Just update UI (you can later add stop endpoint)
      setState(() {
        _isOn = false;
      });
      _showSnackBar("🛑 Detection stopped.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: kPrimaryDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Welcome,',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    color: kPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This is your dashboard. You can access your profile\nand other app features here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 50),

                // 🔘 Toggle Button
                GestureDetector(
                  onTap: _toggleSwitch,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isOn ? Colors.green.shade600 : kPrimaryDark,
                      borderRadius: BorderRadius.circular(kBorderRadius * 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : Text(
                            _isOn ? 'ON' : 'OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  _isOn
                      ? '✅ The system is actively monitoring.'
                      : '⏸ The system is currently inactive.',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isOn ? Colors.green.shade700 : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // 🔐 Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kBorderRadius * 2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32 + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
