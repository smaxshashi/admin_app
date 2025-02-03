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
  required String? gender,
}) async {
  try {
    print(" Calling API for categoryId: $categoryId, gender: $gender");
    emit(SubCategoryLoading()); // 👈 Check if this prints
    print("State Changed to: SubCategoryLoading");

    final subcategories = await subCategoryRepository.fetchSubCategories(
      categoryId: categoryId,
      gender: gender,
    );

    print("✅ API Response: ${subcategories.length} subcategories found");
    emit(SubCategoryLoaded(subcategories)); // 👈 Check if this prints
    print("🟢 State Changed to: SubCategoryLoaded");
  } catch (e) {
    print("❌ Error: $e");
    emit(SubCategoryError('Failed to load subcategories: $e'));
  }
}

}
