part of 'add_product_bloc.dart';

abstract class AddProductState {}

class AddProductInitial extends AddProductState {}

class AddProductLoading extends AddProductState {}

class AddProductCategoriesLoaded extends AddProductState {
  final List<Category> categories;

  AddProductCategoriesLoaded(this.categories);
}

class AddProductError extends AddProductState {
  final String message;

  AddProductError(this.message);
}
