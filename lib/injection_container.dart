import 'package:dio/dio.dart';
import 'package:doctor_care/data/datasources/blood_pressure_data_sources.dart';
import 'package:doctor_care/data/datasources/hba1c_data_sources.dart';
import 'package:doctor_care/data/datasources/temperature_data_sources.dart';
import 'package:doctor_care/data/repositories/blood_pressure_repositoryimpl.dart';
import 'package:doctor_care/data/repositories/hba1c_repositoryimpl.dart';
import 'package:doctor_care/data/repositories/temperature_repositoryimpl.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/delete_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/get_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/insert_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/blood_pressure/update_blood_pressure.dart';
import 'package:doctor_care/domain/usecase/hba1c/delete_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/get_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/insert_hba1c.dart';
import 'package:doctor_care/domain/usecase/hba1c/update_hba1c.dart';
import 'package:doctor_care/domain/usecase/temperature/delete_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/get_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/insert_temperature.dart';
import 'package:doctor_care/domain/usecase/temperature/update_temperature.dart';

// SpO2 Imports
import 'package:doctor_care/data/datasources/spO2heartrate_data_source.dart';
import 'package:doctor_care/data/repositories/Spo2heartrate_repositoty_impl.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/get_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/insert_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/update_spO2heartrate.dart';
import 'package:doctor_care/domain/usecase/spO2heartrate/delete_spO2heartrate.dart';

// BMI Imports
import 'package:doctor_care/data/datasources/bmi_weight_data_source.dart';
import 'package:doctor_care/data/repositories/bmi_weight_repository_impl.dart';
import 'package:doctor_care/domain/usecase/BMI/get_bmiweight.dart';
import 'package:doctor_care/domain/usecase/BMI/insert_bmiweight.dart';
import 'package:doctor_care/domain/usecase/BMI/update_bmiweight.dart';
import 'package:doctor_care/domain/usecase/BMI/delete_bmiweight.dart';

// Auth Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_care/data/datasources/auth_remote_datasource.dart';
import 'package:doctor_care/data/repositories/auth_repository_impl.dart';
import 'package:doctor_care/domain/repositories/auth_repository.dart';
import 'package:doctor_care/domain/usecase/auth/check_auth_status_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/sign_in_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/sign_in_with_google_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/sign_up_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/sign_out_usecase.dart';
import 'package:doctor_care/domain/usecase/auth/reset_password_usecase.dart';

// Meal Analysis Imports
import 'package:doctor_care/core/services/gemini_ai_service.dart';
import 'package:doctor_care/data/datasources/meal_analysis_local_datasource.dart';
import 'package:doctor_care/data/repositories/meal_analysis_repository_impl.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/analyze_meal_image_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/save_meal_analysis_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/get_all_meal_analyses_usecase.dart';
import 'package:doctor_care/domain/usecase/meal_analysis/delete_meal_analysis_usecase.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';

// Database
import 'package:doctor_care/core/db/db_helper.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  final dio = Dio();

  Hba1cRepositoryimpl? _hba1cRepository;
  BloodPressureRepositoryImpl? _bloodPressureRepository;
  TemperatureRepositoryImpl? _temperatureRepository;

  //usecase
  GetHba1c? _getHba1c;
  InsertHba1c? _insertHba1c;
  UpdateHba1c? _updateHba1c;
  DeleteHba1c? _deleteHba1c;

  GetBloodPressure? _getBloodPressure;
  InsertBloodPressure? _insertBloodPressure;
  UpdateBloodPressure? _updateBloodPressure;
  DeleteBloodPressure? _deleteBloodPressure;

  GetTemperature? _getTemperature;
  InsertTemperature? _insertTemperature;
  UpdateTemperature? _updateTemperature;
  DeleteTemperature? _deleteTemperature;

  // SpO2 fields
  Spo2heartrateRepositotyImpl? _spo2heartrateRepository;
  GetSpo2heartrate? _getSpo2heartrate;
  InsertSpo2heartrate? _insertSpo2heartrate;
  UpdateSpo2heartrate? _updateSpo2heartrate;
  DeleteSpo2heartrate? _deleteSpo2heartrate;

  // BMI fields
  BMIWeightRepositoryImpl? _bmiWeightRepository;
  GetBMIWeight? _getBMIWeight;
  InsertBmiweight? _insertBmiweight;
  UpdateBmiWeight? _updateBmiWeight;
  DeleteBmiweight? _deleteBmiweight;

  // Meal Analysis fields
  MealAnalysisRepositoryImpl? _mealAnalysisRepository;
  AnalyzeMealImageUseCase? _analyzeMealImageUseCase;
  SaveMealAnalysisUseCase? _saveMealAnalysisUseCase;
  GetAllMealAnalysesUseCase? _getAllMealAnalysesUseCase;
  DeleteMealAnalysisUseCase? _deleteMealAnalysisUseCase;
  MealAnalysisBloc? _mealAnalysisBloc;

  // Auth fields
  AuthRepository? _authRepository;
  SignInUseCase? _signInUseCase;
  SignInWithGoogleUseCase? _signInWithGoogleUseCase;
  SignUpUseCase? _signUpUseCase;
  SignOutUseCase? _signOutUseCase;
  CheckAuthStatusUseCase? _checkAuthStatusUseCase;
  ResetPasswordUseCase? _resetPasswordUseCase;

  // Repository Getters
  Hba1cRepositoryimpl get hba1cRepository => _hba1cRepository!;
  BloodPressureRepositoryImpl get bloodPressureRepository =>
      _bloodPressureRepository!;
  TemperatureRepositoryImpl get temperatureRepository =>
      _temperatureRepository!;
  Spo2heartrateRepositotyImpl get spo2heartrateRepository =>
      _spo2heartrateRepository!;
  BMIWeightRepositoryImpl get bmiWeightRepository => _bmiWeightRepository!;

  //Usecase Getters
  GetHba1c get getHba1c => _getHba1c!;
  InsertHba1c get insertHba1c => _insertHba1c!;
  UpdateHba1c get updateHba1c => _updateHba1c!;
  DeleteHba1c get deleteHba1c => _deleteHba1c!;

  GetBloodPressure get getBloodPressure => _getBloodPressure!;
  InsertBloodPressure get insertBloodPressure => _insertBloodPressure!;
  UpdateBloodPressure get updateBloodPressure => _updateBloodPressure!;
  DeleteBloodPressure get deleteBloodPressure => _deleteBloodPressure!;

  GetTemperature get getTemperature => _getTemperature!;
  InsertTemperature get insertTemperature => _insertTemperature!;
  UpdateTemperature get updateTemperature => _updateTemperature!;
  DeleteTemperature get deleteTemperature => _deleteTemperature!;

  // SpO2 UseCase Getters
  GetSpo2heartrate get getSpo2heartrate => _getSpo2heartrate!;
  InsertSpo2heartrate get insertSpo2heartrate => _insertSpo2heartrate!;
  UpdateSpo2heartrate get updateSpo2heartrate => _updateSpo2heartrate!;
  DeleteSpo2heartrate get deleteSpo2heartrate => _deleteSpo2heartrate!;

  // BMI UseCase Getters
  GetBMIWeight get getBMIWeight => _getBMIWeight!;
  InsertBmiweight get insertBmiweight => _insertBmiweight!;
  UpdateBmiWeight get updateBmiWeight => _updateBmiWeight!;
  DeleteBmiweight get deleteBmiweight => _deleteBmiweight!;

  // Meal Analysis Getters
  MealAnalysisBloc get mealAnalysisBloc => _mealAnalysisBloc!;

  // Auth UseCase Getters
  SignInUseCase get signInUseCase => _signInUseCase!;
  SignInWithGoogleUseCase get signInWithGoogleUseCase =>
      _signInWithGoogleUseCase!;
  SignUpUseCase get signUpUseCase => _signUpUseCase!;
  SignOutUseCase get signOutUseCase => _signOutUseCase!;
  CheckAuthStatusUseCase get checkAuthStatusUseCase => _checkAuthStatusUseCase!;
  ResetPasswordUseCase get resetPasswordUseCase => _resetPasswordUseCase!;

  // DbHelper instance for direct database access
  late final DbHelper dbHelper = DbHelper.instance;

  Future<void> init() async {
    // Auth
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: firebaseAuth,
      firestore: firestore,
    );
    _authRepository = AuthRepositoryImpl(authRemoteDataSource);
    _signInUseCase = SignInUseCase(_authRepository!);
    _signInWithGoogleUseCase = SignInWithGoogleUseCase(_authRepository!);
    _signUpUseCase = SignUpUseCase(_authRepository!);
    _signOutUseCase = SignOutUseCase(_authRepository!);
    _checkAuthStatusUseCase = CheckAuthStatusUseCase(_authRepository!);
    _resetPasswordUseCase = ResetPasswordUseCase(_authRepository!);

    //theo dõi HbA1c
    final hba1DataSources = Hba1cDataSourcesImpl();
    _hba1cRepository = Hba1cRepositoryimpl(hba1DataSources);
    _getHba1c = GetHba1c(_hba1cRepository!);
    _insertHba1c = InsertHba1c(_hba1cRepository!);
    _updateHba1c = UpdateHba1c(_hba1cRepository!);
    _deleteHba1c = DeleteHba1c(_hba1cRepository!);

    // theo dõi huyết áp
    final bloodPressureDataSources = BloodPressureDataSourcesImpl();
    _bloodPressureRepository = BloodPressureRepositoryImpl(
      bloodPressureDataSources,
    );
    _getBloodPressure = GetBloodPressure(_bloodPressureRepository!);
    _insertBloodPressure = InsertBloodPressure(_bloodPressureRepository!);
    _updateBloodPressure = UpdateBloodPressure(_bloodPressureRepository!);
    _deleteBloodPressure = DeleteBloodPressure(_bloodPressureRepository!);

    final temperatureDataSources = TemperatureDataSourceImpl();
    _temperatureRepository = TemperatureRepositoryImpl(temperatureDataSources);
    _getTemperature = GetTemperature(_temperatureRepository!);
    _insertTemperature = InsertTemperature(_temperatureRepository!);
    _updateTemperature = UpdateTemperature(_temperatureRepository!);
    _deleteTemperature = DeleteTemperature(_temperatureRepository!);

    // SpO2
    final spo2DataSource = Spo2heartrateDataSourceImpl();
    _spo2heartrateRepository = Spo2heartrateRepositotyImpl(spo2DataSource);
    _getSpo2heartrate = GetSpo2heartrate(_spo2heartrateRepository!);
    _insertSpo2heartrate = InsertSpo2heartrate(_spo2heartrateRepository!);
    _updateSpo2heartrate = UpdateSpo2heartrate(_spo2heartrateRepository!);
    _deleteSpo2heartrate = DeleteSpo2heartrate(_spo2heartrateRepository!);

    // BMI
    final bmiDataSource = BMIWeightDataSourceImpl();
    _bmiWeightRepository = BMIWeightRepositoryImpl(bmiDataSource);
    _getBMIWeight = GetBMIWeight(repository: _bmiWeightRepository!);
    _insertBmiweight = InsertBmiweight(repository: _bmiWeightRepository!);
    _updateBmiWeight = UpdateBmiWeight(repository: _bmiWeightRepository!);
    _deleteBmiweight = DeleteBmiweight(repository: _bmiWeightRepository!);

    // Meal Analysis
    final mealAnalysisLocalDataSource = MealAnalysisLocalDataSource();
    final geminiAIService = GeminiAIService();
    _mealAnalysisRepository = MealAnalysisRepositoryImpl(
      mealAnalysisLocalDataSource,
      geminiAIService,
    );
    _analyzeMealImageUseCase = AnalyzeMealImageUseCase(
      _mealAnalysisRepository!,
    );
    _saveMealAnalysisUseCase = SaveMealAnalysisUseCase(
      _mealAnalysisRepository!,
    );
    _getAllMealAnalysesUseCase = GetAllMealAnalysesUseCase(
      _mealAnalysisRepository!,
    );
    _deleteMealAnalysisUseCase = DeleteMealAnalysisUseCase(
      _mealAnalysisRepository!,
    );

    _mealAnalysisBloc = MealAnalysisBloc(
      analyzeMealImageUseCase: _analyzeMealImageUseCase!,
      saveMealAnalysisUseCase: _saveMealAnalysisUseCase!,
      getAllMealAnalysesUseCase: _getAllMealAnalysesUseCase!,
      deleteMealAnalysisUseCase: _deleteMealAnalysisUseCase!,
    );
  }

  void dispose() {
    dio.close();
  }
}
