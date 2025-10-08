import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../components/glass/glass.dart';
import '../../components/backgrounds/space_background.dart';
import '../../helpers/widgets/my_spacing.dart';
import '../../helpers/widgets/my_text.dart';
import '../../helpers/widgets/my_button.dart';
import '../../helpers/widgets/my_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey _backgroundKey = GlobalKey();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: MyText.bodyMedium(e.toString(), color: Colors.white),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInAnonymously();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: MyText.bodyMedium(e.toString(), color: Colors.white),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  SpaceBackgroundState backgroundState() => SpaceBackgroundState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleSpaceBackground(
        backgroundKey: _backgroundKey,
        state: backgroundState(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48, // Account for padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Title
                Container(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox.shrink(),
                      MyText.titleLarge(
                        'MontaNAgent',
                        style: TextStyle(fontWeight: FontWeight.w700),
                        color: Theme.of(context).primaryColor,
                      ),
                      MySpacing.height(8),
                      MyText.bodyLarge(
                        'Your AI Recovery Companion',
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),

                // Login Form
                GlassCard(
                  backgroundKey: _backgroundKey,
                  padding: EdgeInsets.zero,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        MyCard(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      SizedBox.shrink(),
                        MyCard(
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                      SizedBox.shrink(),
                        MyButton.large(
                          _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : MyText.bodyLarge('Sign In', color: Colors.white),
                          onPressed: _isLoading ? null : _signIn,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox.shrink(),

                // Alternative Options Card
                GlassCard(
                  backgroundKey: _backgroundKey,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.zero,
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      SizedBox.shrink(),

                      // Anonymous Sign In
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _signInAnonymously,
                          child: const Text('Continue as Guest'),
                        ),
                      ),

                      SizedBox.shrink(),

                      // Sign Up Link
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Don\'t have an account? Sign Up'),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
