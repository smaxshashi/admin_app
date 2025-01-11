part of 'add_product_bloc.dart';

abstract class AddProductEvent {}

class FetchCategoriesEvent extends AddProductEvent {
  final String wholeseller;

  FetchCategoriesEvent(this.wholeseller);
}
