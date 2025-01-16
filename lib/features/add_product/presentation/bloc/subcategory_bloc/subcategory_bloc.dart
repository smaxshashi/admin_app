import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';

part 'subcategory_event.dart';
part 'subcategory_state.dart';

class SubCategoryBloc extends Cubit<SubCategoryState> {
  final SubCategoryRepository subCategoryRepository;

  SubCategoryBloc(this.subCategoryRepository) : super(SubCategoryInitial());

  Future<void> loadSubCategories({
    required int categoryId,
    required String? gender, // Changed from int? to String?
  }) async {
    try {
      emit(SubCategoryLoading());
      final subcategories = await subCategoryRepository.fetchSubCategories(
        categoryId: categoryId,
        gender: gender, // Pass gender as String?
      );
      emit(SubCategoryLoaded(subcategories));
    } catch (e) {
      emit(SubCategoryError('Failed to load subcategories: $e'));
    }
  }
}
