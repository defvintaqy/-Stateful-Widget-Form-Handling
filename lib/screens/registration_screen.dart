import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // Latihan 1
  final _dobController = TextEditingController(); // Latihan 2
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedDate; // Latihan 2
  String? _selectedGender; // Latihan 3
  bool _agreeTerms = false; // Latihan 4
  bool _termsError = false; // Latihan 4

  // Latihan 5: State Kekuatan Password
  String _passwordStrength = '';
  double _passwordProgress = 0.0;
  Color _passwordColor = Colors.grey;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Method Date Picker (Latihan 2)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // Latihan 5: Logika Hitung Kekuatan Password
  void _checkPasswordStrength(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordProgress = 0.0;
        _passwordColor = Colors.grey;
      });
      return;
    }

    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (value.length >= 8 && hasUpper && hasLower && hasDigits && hasSpecial) {
      // Kuat: >= 8 karakter, huruf kapital, huruf kecil, angka, dan simbol
      setState(() {
        _passwordStrength = 'Kuat';
        _passwordProgress = 1.0;
        _passwordColor = Colors.green;
      });
    } else if (value.length >= 8 && ((hasUpper || hasLower) && hasDigits)) {
      // Sedang: >= 8 karakter, mengandung huruf dan angka
      setState(() {
        _passwordStrength = 'Sedang';
        _passwordProgress = 0.66;
        _passwordColor = Colors.orange;
      });
    } else {
      // Lemah: < 8 karakter atau kriteria lain belum terpenuhi
      setState(() {
        _passwordStrength = 'Lemah';
        _passwordProgress = 0.33;
        _passwordColor = Colors.red;
      });
    }
  }

  // Validasi Nama
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  // Validasi Email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // Validasi Nomor Telepon (Latihan 1)
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final numericRegExp = RegExp(r'^[0-9]+$');
    if (!numericRegExp.hasMatch(value.trim())) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    if (value.trim().length < 10 || value.trim().length > 13) {
      return 'Nomor telepon harus antara 10 hingga 13 digit';
    }
    return null;
  }

  // Validasi Tanggal Lahir (Latihan 2)
  String? _validateDOB(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tanggal lahir wajib diisi';
    }
    return null;
  }

  // Validasi Jenis Kelamin (Latihan 3)
  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Jenis kelamin wajib dipilih';
    }
    return null;
  }

  // Validasi Password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf kapital';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  // Validasi Konfirmasi Password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  // Submit Handler
  void _submitForm() {
    setState(() {
      _termsError = !_agreeTerms;
    });

    if (_formKey.currentState!.validate() && _agreeTerms) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registrasi Berhasil'),
            content: Text(
              'Selamat, ${_nameController.text}!\n'
              'Email: ${_emailController.text}\n'
              'No. Telp: ${_phoneController.text}\n'
              'Tgl Lahir: ${_dobController.text}\n'
              'Jenis Kelamin: $_selectedGender',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  // Reset Handler
  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _dobController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedDate = null;
      _selectedGender = null;
      _agreeTerms = false;
      _termsError = false;
      _passwordStrength = '';
      _passwordProgress = 0.0;
      _passwordColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Registrasi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi form di bawah ini untuk mendaftar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Field Nama
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person,
                  validator: _validateName,
                ),

                // Field Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

                // Field Nomor Telepon (Latihan 1)
                CustomTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  hint: 'Masukkan nomor telepon (10-13 digit)',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),

                // Field Tanggal Lahir (Latihan 2)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'Pilih tanggal lahir',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFFAFAFA),
                    ),
                    validator: _validateDOB,
                  ),
                ),

                // Dropdown Jenis Kelamin (Latihan 3)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      hintText: 'Pilih jenis kelamin',
                      prefixIcon: Icon(Icons.people),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFFFAFAFA),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Laki-laki',
                        child: Text('Laki-laki'),
                      ),
                      DropdownMenuItem(
                        value: 'Perempuan',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: _validateGender,
                  ),
                ),

                // Field Password & Indikator Kekuatan (Latihan 5)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Minimal 8 karakter, huruf kapital, angka',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        obscureText: _obscurePassword,
                        onChanged: _checkPasswordStrength, // Trigger Latihan 5
                        validator: _validatePassword,
                      ),
                      if (_passwordStrength.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _passwordProgress,
                            color: _passwordColor,
                            backgroundColor: Colors.grey[200],
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kekuatan Password: $_passwordStrength',
                          style: TextStyle(
                            color: _passwordColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Field Konfirmasi Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'Ulangi password Anda',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                  ),
                ),

                // Checkbox Syarat & Ketentuan (Latihan 4)
                CheckboxListTile(
                  title: const Text(
                    'Saya menyetujui Syarat & Ketentuan yang berlaku',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _agreeTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeTerms = value ?? false;
                      if (_agreeTerms) {
                        _termsError = false;
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_termsError)
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                    child: Text(
                      'Anda harus menyetujui syarat & ketentuan',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 16),

                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Daftar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),

                // Tombol Reset
                OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}