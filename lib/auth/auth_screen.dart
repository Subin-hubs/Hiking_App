import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmController = TextEditingController();

  bool _isLoading = false;
  bool _loginPasswordVisible = false;
  bool _signupPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[700]),
    );
  }

  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password. Try again.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password': return 'Password must be at least 6 characters.';
      case 'invalid-email': return 'Please enter a valid email address.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      case 'network-request-failed': return 'No internet connection.';
      default: return e.message ?? 'An error occurred. Please try again.';
    }
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmail(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showError(_parseFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmail(
        _signupEmailController.text,
        _signupPasswordController.text,
        _signupNameController.text,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showError(_parseFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Google sign in failed. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_loginEmailController.text.isEmpty) {
      _showError('Enter your email first then tap forgot password.');
      return;
    }
    try {
      await _authService.resetPassword(_loginEmailController.text);
      _showSuccess('Password reset email sent!');
    } on FirebaseAuthException catch (e) {
      _showError(_parseFirebaseError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero ──
            Container(
              height: screenHeight * 0.28,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[900]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.terrain, color: Colors.white, size: 52),
                    const SizedBox(height: 10),
                    Text(
                      'NepalHike',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Explore the Himalayas',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tab Bar ──
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.green[700],
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green[700],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: const [
                  Tab(text: 'Login'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),

            // ── Forms ──
            SizedBox(
              height: screenHeight * 0.65,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginForm(screenWidth),
                  _buildSignupForm(screenWidth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(double screenWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Welcome back!',
                style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
            Text('Sign in to continue your adventure.',
                style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.033)),
            const SizedBox(height: 24),

            _inputField(
              controller: _loginEmailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Enter your email' : null,
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _loginPasswordController,
              label: 'Password',
              icon: Icons.lock_outlined,
              obscure: !_loginPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(_loginPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _loginPasswordVisible = !_loginPasswordVisible),
              ),
              validator: (v) => v!.isEmpty ? 'Enter your password' : null,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: Text('Forgot password?', style: TextStyle(color: Colors.green[700])),
              ),
            ),

            const SizedBox(height: 8),
            _primaryButton('Login', _isLoading ? null : _login),
            const SizedBox(height: 16),
            _divider(),
            const SizedBox(height: 16),
            _googleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(double screenWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Create account',
                style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold)),
            Text('Join thousands of Nepal trekkers.',
                style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.033)),
            const SizedBox(height: 24),

            _inputField(
              controller: _signupNameController,
              label: 'Full Name',
              icon: Icons.person_outlined,
              validator: (v) => v!.isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _signupEmailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Enter your email' : null,
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _signupPasswordController,
              label: 'Password',
              icon: Icons.lock_outlined,
              obscure: !_signupPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(_signupPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _signupPasswordVisible = !_signupPasswordVisible),
              ),
              validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 14),
            _inputField(
              controller: _signupConfirmController,
              label: 'Confirm Password',
              icon: Icons.lock_outlined,
              obscure: true,
              validator: (v) => v != _signupPasswordController.text ? 'Passwords do not match' : null,
            ),

            const SizedBox(height: 24),
            _primaryButton('Create Account', _isLoading ? null : _signup),
            const SizedBox(height: 16),
            _divider(),
            const SizedBox(height: 16),
            _googleButton(),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.green[700]!, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20, width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _googleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.google.com/favicon.ico',
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}