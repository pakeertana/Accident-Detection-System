import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId; // ✅ Pass userId from signup

  const UserDetailsPage({super.key, required this.userId});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final supabase = Supabase.instance.client;

  final _ownerNameController = TextEditingController();
  final _carModelController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _rcNumberController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  @override
  void dispose() {
    _ownerNameController.dispose();
    _carModelController.dispose();
    _licenseNumberController.dispose();
    _rcNumberController.dispose();
    _contactNumberController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _submitDetails() async {
    final ownerName = _ownerNameController.text.trim();
    final carModel = _carModelController.text.trim();
    final licenseNumber = _licenseNumberController.text.trim();
    final rcNumber = _rcNumberController.text.trim();
    final contactNumber = _contactNumberController.text.trim();
    final emergencyContact = _emergencyContactController.text.trim();

    if (ownerName.isEmpty ||
        carModel.isEmpty ||
        licenseNumber.isEmpty ||
        rcNumber.isEmpty ||
        contactNumber.isEmpty ||
        emergencyContact.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    try {
      // ✅ Modern Supabase insert (no .error check)
      await supabase.from('profiles').insert({
        'user_id': widget.userId,
        'owner_name': ownerName,
        'car_model': carModel,
        'license_number': licenseNumber,
        'rc_number': rcNumber,
        'contact_number': contactNumber,
        'emergency_contact': emergencyContact,
      });

      developer.log('Profile saved successfully', name: 'UserDetails');
      _showMessage('Details saved successfully!');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } on PostgrestException catch (e) {
      // ✅ Handles database-related errors properly
      developer.log('PostgrestException: ${e.message}', name: 'UserDetails');
      _showMessage('Database Error: ${e.message}');
    } catch (e) {
      // ✅ Handles any other error type (null, network, etc.)
      developer.log('Exception: $e', name: 'UserDetails');
      _showMessage('An unexpected error occurred: $e');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E232C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please fill in your information below.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              _buildCustomTextField(_ownerNameController, 'Car Owner Name'),
              const SizedBox(height: 16),
              _buildCustomTextField(_carModelController, 'Car Model Name'),
              const SizedBox(height: 16),
              _buildCustomTextField(
                _licenseNumberController,
                'Owner License Number',
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(_rcNumberController, 'Vehicle RC Number'),
              const SizedBox(height: 16),
              _buildCustomTextField(
                _contactNumberController,
                'Owner Contact Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                _emergencyContactController,
                'Emergency Contact Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E232C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Submit Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF7F8F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
    );
  }
}
