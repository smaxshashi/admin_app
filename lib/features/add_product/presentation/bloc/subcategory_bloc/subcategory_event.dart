part of 'subcategory_bloc.dart';

abstract class SubCategoryEvent {}

class FetchSubCategoriesEvent extends SubCategoryEvent {
  final int categoryId;
  final int gender;

  FetchSubCategoriesEvent({
    required this.categoryId,
    required this.gender,
  });
}
