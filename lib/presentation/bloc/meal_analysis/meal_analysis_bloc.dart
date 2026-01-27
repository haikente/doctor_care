import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/analyze_meal_image_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/save_meal_analysis_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/get_all_meal_analyses_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/delete_meal_analysis_usecase.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';

/// BLoC for managing meal analysis state
class MealAnalysisBloc extends Bloc<MealAnalysisEvent, MealAnalysisState> {
  final AnalyzeMealImageUseCase analyzeMealImageUseCase;
  final SaveMealAnalysisUseCase saveMealAnalysisUseCase;
  final GetAllMealAnalysesUseCase getAllMealAnalysesUseCase;
  final DeleteMealAnalysisUseCase deleteMealAnalysisUseCase;

  MealAnalysisBloc({
    required this.analyzeMealImageUseCase,
    required this.saveMealAnalysisUseCase,
    required this.getAllMealAnalysesUseCase,
    required this.deleteMealAnalysisUseCase,
  }) : super(const MealAnalysisInitial()) {
    on<AnalyzeMealImageEvent>(_onAnalyzeMealImage);
    on<SaveMealAnalysisEvent>(_onSaveMealAnalysis);
    on<LoadMealAnalysesEvent>(_onLoadMealAnalyses);
    on<DeleteMealAnalysisEvent>(_onDeleteMealAnalysis);
  }

  Future<void> _onAnalyzeMealImage(
    AnalyzeMealImageEvent event,
    Emitter<MealAnalysisState> emit,
  ) async {
    emit(const MealAnalysisLoading());

    final result = await analyzeMealImageUseCase(event.imagePath);

    result.fold(
      ifLeft: (error) => emit(MealAnalysisError(error.toString())),
      ifRight: (mealAnalysis) => emit(MealAnalysisSuccess(mealAnalysis)),
    );
  }

  Future<void> _onSaveMealAnalysis(
    SaveMealAnalysisEvent event,
    Emitter<MealAnalysisState> emit,
  ) async {
    emit(const MealAnalysisLoading());

    final result = await saveMealAnalysisUseCase(event.mealAnalysis);

    result.fold(
      ifLeft: (error) => emit(MealAnalysisError(error.toString())),
      ifRight: (mealId) {
        emit(MealAnalysisSaved(mealId));
        // Reload meal analyses after saving
        add(const LoadMealAnalysesEvent());
      },
    );
  }

  Future<void> _onLoadMealAnalyses(
    LoadMealAnalysesEvent event,
    Emitter<MealAnalysisState> emit,
  ) async {
    emit(const MealAnalysisLoading());

    final result = await getAllMealAnalysesUseCase();

    result.fold(
      ifLeft: (error) => emit(MealAnalysisError(error.toString())),
      ifRight: (mealAnalyses) => emit(MealAnalysesLoaded(mealAnalyses)),
    );
  }

  Future<void> _onDeleteMealAnalysis(
    DeleteMealAnalysisEvent event,
    Emitter<MealAnalysisState> emit,
  ) async {
    emit(const MealAnalysisLoading());

    final result = await deleteMealAnalysisUseCase(event.id);

    result.fold(
      ifLeft: (error) => emit(MealAnalysisError(error.toString())),
      ifRight: (_) {
        emit(const MealAnalysisDeleted());
        // Reload meal analyses after deleting
        add(const LoadMealAnalysesEvent());
      },
    );
  }
}
