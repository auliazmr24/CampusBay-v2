import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../main/main_nav.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text("Welcome back,\nStudent!", style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text("Masuk pakai email kampus biar trusted.", style: Theme.of(context).textTheme.bodyLarge),
              
              const SizedBox(height: 40),
              
              const TextField(
                decoration: InputDecoration(
                  labelText: "Email Kampus (.ac.id)",
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, 
                      MaterialPageRoute(builder: (context) => const MainNav())
                    );
                  },
                  child: const Text("LOGIN"),
                ),
              ),
              
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum verified? "),
                  GestureDetector(
                    onTap: (){}, // Ke Register
                    child: Text("Daftar Sekarang", 
                      style: TextStyle(
                        color: AppColors.oxidizedIron, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}