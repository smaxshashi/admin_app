import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/apis/login_api.dart';
import 'package:gehnaorg/features/add_product/data/repositories/login_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';

class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> initialize() async {
    // Register Dio
    _getIt.registerSingleton<Dio>(Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));

    // Register Repositories
    _getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepository(_getIt<Dio>()),
    );

    _getIt.registerLazySingleton<SubCategoryRepository>(
      () => SubCategoryRepository(_getIt<Dio>()),
    );

    _getIt.registerLazySingleton<LoginApi>(
      () => LoginApi(_getIt<Dio>()),
    );

    _getIt.registerLazySingleton<LoginRepository>(
      () => LoginRepository(_getIt<LoginApi>()),
    );

    // Register BLoCs
    _getIt.registerFactory<AddProductBloc>(
      () => AddProductBloc(
        categoryRepository: _getIt<CategoryRepository>(),
        subCategoryRepository: _getIt<SubCategoryRepository>(),
      ),
    );

    _getIt.registerFactory<LoginBloc>(
      () => LoginBloc(
        loginRepository: _getIt<LoginRepository>(),
      ),
    );
  }

  static T resolve<T extends Object>() => _getIt<T>();
}
