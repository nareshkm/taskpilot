import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

/// A login page prompting for email and password
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authNotifierProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v != null && v.contains('@')) ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) =>
                      (v != null && v.isNotEmpty) ? null : 'Enter a password',
                ),
                const SizedBox(height: 24),
                if (authState.error != null) ...[
                  Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                ],
                authState.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Login'),
                        ),
                      ),
                const SizedBox(height: 24),
                const Text('Or login with'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google login not implemented'))),
                    ),
                    IconButton(
                      icon: const Icon(Icons.login),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Facebook login not implemented'))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}