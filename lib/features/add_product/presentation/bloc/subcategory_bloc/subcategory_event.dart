part of 'subcategory_bloc.dart';

abstract class SubCategoryEvent {}

class FetchSubCategoriesEvent extends SubCategoryEvent {
  final int categoryCode;
  final int genderCode;
  final String wholeseller;

  FetchSubCategoriesEvent({
    required this.categoryCode,
    required this.genderCode,
    required this.wholeseller,
  });
}
