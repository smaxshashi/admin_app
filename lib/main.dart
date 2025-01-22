import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:gehnaorg/features/add_product/data/repositories/login_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart'; // Import LoginBloc
import 'package:gehnaorg/features/add_product/presentation/pages/add_product_page.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/home_page.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/lightweight_page.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/login_page.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/banner_screen.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/prices_page.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/profile_page.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/testimonial_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/di_container.dart'; // Dependency Injection

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check login status
  final isLoggedIn = await isUserLoggedIn();

  // Initialize the dependency injection container
  await DependencyInjection.initialize();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LoginBloc(
            loginRepository: DependencyInjection.resolve<LoginRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => DependencyInjection.resolve<AddProductBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return MaterialApp(
            title: 'GehnaMall',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.grey[100],
            ),
            home: isLoggedIn ? HomePage() : LoginPage(),
            routes: {
              '/add_product': (context) => const AddProductPage(),
              '/home': (context) => const HomePage(),
              '/profile': (context) => ProfilePage(),
              '/others': (context) => BannerAndTestimonialPage(),
              '/light_weight': (context) => const LightweightPage(),
              '/prices': (context) => const PricesPage(),
              '/testi': (context) => const TestimonialPage(),
            },
          );
        },
      ),
    );
  }
}
Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('token');
}
