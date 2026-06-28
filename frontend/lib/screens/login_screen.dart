import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController(text: 'admin@loanledger.lk');
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;

  Future<void> _login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      toast(context, 'Enter email and password'); return;
    }
    setState(() => loading = true);
    try {
      await ref.read(authRepoProvider).login(email.text.trim(), password.text);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeShell()));
      }
    } catch (_) {
      if (mounted) toast(context, 'Login failed. Check your credentials and API URL.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(width: 64, height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.borrow]),
                    borderRadius: BorderRadius.circular(18)),
                  alignment: Alignment.center,
                  child: const Text('L', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800))),
              const SizedBox(height: 18),
              const Text('LoanLedger', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              Text('Admin sign in', textAlign: TextAlign.center, style: TextStyle(color: mutedColor(context))),
              const SizedBox(height: 28),
              TextField(controller: email, keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: password, obscureText: obscure,
                  decoration: InputDecoration(labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => obscure = !obscure)))),
              const SizedBox(height: 20),
              FilledButton(onPressed: loading ? null : _login,
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign in')),
            ]),
          ),
        ),
      ),
    );
  }
}
