import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart';

import '../../../../core/constants/constants.dart';


class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 235, 235),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              color: kWhite,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    
                    children: [
                      Text('LOGIN',
                      style: TextStyle(
                        letterSpacing: 1,
                        color: kPrimary,
                        fontSize: 40 ,
                      ),),
                        SizedBox(
                          height: 40,
                        ),
                      // Email TextField with Icon
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: kPrimary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: kPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
              
                      // Password TextField with Icon
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: kPrimary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: kPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
              
                      // Login Button
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is LoginLoading
                                ? null
                                : () {
                                    // Dispatch login event
                                    context.read<LoginBloc>().add(
                                          LoginUserEvent(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: state is LoginLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kWhite
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
              
                      // Display Success/Error message
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          if (state is LoginSuccess) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Login Successful!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          } else if (state is LoginFailure) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Error: ${state.error}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
