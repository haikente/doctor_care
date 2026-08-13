import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_care/core/services/gemini_ai_service.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/analyze_meal_image_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/save_meal_analysis_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/get_all_meal_analyses_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/delete_meal_analysis_usecase.dart';
import 'package:doctor_care/data/repositories/meal_analysis_repository_impl.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_state.dart';

class MealAnalysisBloc extends Bloc<MealAnalysisEvent, MealAnalysisState> {
  final AnalyzeMealImageUseCase analyzeMealImageUseCase;
  final SaveMealAnalysisUseCase saveMealAnalysisUseCase;
  final GetAllMealAnalysesUseCase getAllMealAnalysesUseCase;
  final DeleteMealAnalysisUseCase deleteMealAnalysisUseCase;
  final GeminiAIService geminiAIService;

  MealAnalysisBloc({
    required this.analyzeMealImageUseCase,
    required this.saveMealAnalysisUseCase,
    required this.getAllMealAnalysesUseCase,
    required this.deleteMealAnalysisUseCase,
    required this.geminiAIService,
  }) : super(const MealAnalysisInitial()) {
    on<AnalyzeMealImageEvent>(_onAnalyzeMealImage);
    on<SaveMealAnalysisEvent>(_onSaveMealAnalysis);
    on<LoadMealAnalysesEvent>(_onLoadMealAnalyses);
    on<DeleteMealAnalysisEvent>(_onDeleteMealAnalysis);
    on<SuggestMealEvent>(_onSuggestMeal);
  }

  Future<void> _onAnalyzeMealImage(
    AnalyzeMealImageEvent event,
    Emitter<MealAnalysisState> emit,
  ) async {
    emit(const MealAnalysisLoading());

    final result = await analyzeMealImageUseCase(event.imagePath);

    result.fold(
      ifLeft: (error) {
        if (error is InvalidImageException) {
          emit(MealAnalysisInvalidImage(error.reason));
        } else {
          emit(MealAnalysisError(error.toString()));
        }
      },
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
        add(const LoadMealAnalysesEvent());
      },
    );
  }

  /// Xử lý gợi ý bữa ăn từ AI
  Future<void> _onSuggestMeal(
    SuggestMealEvent event,
    Emitter<MealAnalysisState> emit,
  ) async {
    emit(const MealAnalysisLoading());

    try {
      final suggestion = await geminiAIService.suggestMeal(
        mealType: event.mealType,
      );
      emit(MealSuggestionLoaded(suggestion));
    } catch (e) {
      emit(MealAnalysisError(e.toString()));
    }
  }
}
