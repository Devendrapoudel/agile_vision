import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  static const _accounts = [
    _Account(role: 'Devendra — Manager',  email: 'devendra@agilevision.com', password: 'research2026', icon: Icons.manage_accounts_outlined, color: AppColors.devendra),
    _Account(role: 'Roshan — Developer',  email: 'roshan@agilevision.com',   password: 'research2026', icon: Icons.attach_money_outlined,     color: AppColors.roshan),
    _Account(role: 'Shambhu — Developer', email: 'shambhu@agilevision.com',  password: 'research2026', icon: Icons.phonelink_outlined,        color: AppColors.shambhu),
    _Account(role: 'Shiva — Developer',   email: 'shiva@agilevision.com',    password: 'research2026', icon: Icons.cloud_outlined,            color: AppColors.shiva),
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _fill(_Account account) {
    setState(() {
      _emailCtrl.text = account.email;
      _passwordCtrl.text = account.password;
      _error = null;
    });
  }

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await _authService.signIn(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      debugPrint('LOGIN: signIn returned user=${user?.id} role=${user?.role}');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(userRole: user?.role ?? 'developer'),
        ),
      );
    } catch (e, st) {
      debugPrint('LOGIN ERROR: $e\n$st');
      setState(() { _error = 'Login failed: $e'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.insights_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AgileVision',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to monitor your Agile project',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Quick-fill account cards (2×2 grid)
              const Text(
                'Research accounts',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.4),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _AccountCard(account: _accounts[0], onTap: () => _fill(_accounts[0]))),
                  const SizedBox(width: 8),
                  Expanded(child: _AccountCard(account: _accounts[1], onTap: () => _fill(_accounts[1]))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _AccountCard(account: _accounts[2], onTap: () => _fill(_accounts[2]))),
                  const SizedBox(width: 8),
                  Expanded(child: _AccountCard(account: _accounts[3], onTap: () => _fill(_accounts[3]))),
                ],
              ),

              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _signIn(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'University of the West of Scotland — MSc Research Project',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data + widget helpers
// ---------------------------------------------------------------------------

class _Account {
  final String role;
  final String email;
  final String password;
  final IconData icon;
  final Color color;

  const _Account({
    required this.role,
    required this.email,
    required this.password,
    required this.icon,
    required this.color,
  });
}

class _AccountCard extends StatelessWidget {
  final _Account account;
  final VoidCallback onTap;

  const _AccountCard({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: account.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(account.icon, color: account.color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.role, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(account.email, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
