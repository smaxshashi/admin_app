import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';

part 'subcategory_event.dart';
part 'subcategory_state.dart';

class SubCategoryBloc extends Cubit<SubCategoryState> {
  final SubCategoryRepository subCategoryRepository;

  SubCategoryBloc(this.subCategoryRepository) : super(SubCategoryInitial());

  Future<void> loadSubCategories({
    required int categoryCode,
    required int? genderCode, // Make genderCode nullable
    required String wholeseller,
  }) async {
    try {
      emit(SubCategoryLoading());
      final subcategories = await subCategoryRepository.fetchSubCategories(
        categoryCode: categoryCode,
        genderCode: genderCode, // Pass nullable genderCode
        wholeseller: wholeseller,
      );
      emit(SubCategoryLoaded(subcategories));
    } catch (e) {
      emit(SubCategoryError('Failed to load subcategories'));
    }
  }
}
