part of 'subcategory_bloc.dart';

abstract class SubCategoryState {}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategoryLoaded extends SubCategoryState {
  final List<SubCategory> subcategories;

  SubCategoryLoaded(this.subcategories);
}

class SubCategoryError extends SubCategoryState {
  final String message;

  SubCategoryError(this.message);
}
