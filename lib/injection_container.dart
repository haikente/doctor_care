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

// Blood Sugar Imports
import 'package:doctor_care/data/datasources/blood_sugar_data_source.dart';
import 'package:doctor_care/data/repositories/blood_sugar_repository_impl.dart';
import 'package:doctor_care/domain/usecase/blood_sugar/get_blood_sugar.dart';
import 'package:doctor_care/domain/usecase/blood_sugar/insert_blood_sugar.dart';
import 'package:doctor_care/domain/usecase/blood_sugar/update_blood_sugar.dart';
import 'package:doctor_care/domain/usecase/blood_sugar/delete_blood_sugar.dart';

// Sleep Record Imports
import 'package:doctor_care/data/datasources/sleep_record_data_source.dart';
import 'package:doctor_care/data/repositories/sleep_record_repository_impl.dart';
import 'package:doctor_care/domain/usecase/sleep_record/get_sleep_record.dart';
import 'package:doctor_care/domain/usecase/sleep_record/insert_sleep_record.dart';
import 'package:doctor_care/domain/usecase/sleep_record/update_sleep_record.dart';
import 'package:doctor_care/domain/usecase/sleep_record/delete_sleep_record.dart';

// Step Count Imports
import 'package:doctor_care/data/datasources/step_count_data_source.dart';
import 'package:doctor_care/data/repositories/step_count_repository_impl.dart';
import 'package:doctor_care/domain/usecase/step_count/get_step_count.dart';
import 'package:doctor_care/domain/usecase/step_count/insert_step_count.dart';
import 'package:doctor_care/domain/usecase/step_count/update_step_count.dart';
import 'package:doctor_care/domain/usecase/step_count/delete_step_count.dart';

// Cholesterol Imports
import 'package:doctor_care/data/datasources/cholesterol_data_source.dart';
import 'package:doctor_care/data/repositories/cholesterol_repository_impl.dart';
import 'package:doctor_care/domain/usecase/cholesterol/get_cholesterol.dart';
import 'package:doctor_care/domain/usecase/cholesterol/insert_cholesterol.dart';
import 'package:doctor_care/domain/usecase/cholesterol/update_cholesterol.dart';
import 'package:doctor_care/domain/usecase/cholesterol/delete_cholesterol.dart';

// Creatinine Imports
import 'package:doctor_care/data/datasources/creatinine_data_source.dart';
import 'package:doctor_care/data/repositories/creatinine_repository_impl.dart';
import 'package:doctor_care/domain/usecase/creatinine/get_creatinine.dart';
import 'package:doctor_care/domain/usecase/creatinine/insert_creatinine.dart';
import 'package:doctor_care/domain/usecase/creatinine/update_creatinine.dart';
import 'package:doctor_care/domain/usecase/creatinine/delete_creatinine.dart';

// Family Profile Imports
import 'package:doctor_care/data/datasources/family_profile_data_source.dart';
import 'package:doctor_care/data/repositories/family_profile_repository_impl.dart';
import 'package:doctor_care/domain/usecase/family_profile/get_family_profiles.dart';
import 'package:doctor_care/domain/usecase/family_profile/insert_family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/update_family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/delete_family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/set_active_family_profile.dart';
import 'package:doctor_care/domain/usecase/family_profile/get_active_family_profile.dart';

// Water Intake Imports
import 'package:doctor_care/data/datasources/water_intake_data_source.dart';
import 'package:doctor_care/data/repositories/water_intake_repository_impl.dart';
import 'package:doctor_care/domain/usecase/water_intake/get_water_intake.dart';
import 'package:doctor_care/domain/usecase/water_intake/insert_water_intake.dart';
import 'package:doctor_care/domain/usecase/water_intake/update_water_intake.dart';
import 'package:doctor_care/domain/usecase/water_intake/delete_water_intake.dart';

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

  // Blood Sugar fields
  BloodSugarRepositoryImpl? _bloodSugarRepository;
  GetBloodSugar? _getBloodSugar;
  InsertBloodSugar? _insertBloodSugar;
  UpdateBloodSugar? _updateBloodSugar;
  DeleteBloodSugar? _deleteBloodSugar;

  // Sleep Record fields
  SleepRecordRepositoryImpl? _sleepRecordRepository;
  GetSleepRecord? _getSleepRecord;
  InsertSleepRecord? _insertSleepRecord;
  UpdateSleepRecord? _updateSleepRecord;
  DeleteSleepRecord? _deleteSleepRecord;

  // Step Count fields
  StepCountRepositoryImpl? _stepCountRepository;
  GetStepCount? _getStepCount;
  InsertStepCount? _insertStepCount;
  UpdateStepCount? _updateStepCount;
  DeleteStepCount? _deleteStepCount;

  // Cholesterol fields
  CholesterolRepositoryImpl? _cholesterolRepository;
  GetCholesterol? _getCholesterol;
  InsertCholesterol? _insertCholesterol;
  UpdateCholesterol? _updateCholesterol;
  DeleteCholesterol? _deleteCholesterol;

  // Creatinine fields
  CreatinineRepositoryImpl? _creatinineRepository;
  GetCreatinine? _getCreatinine;
  InsertCreatinine? _insertCreatinine;
  UpdateCreatinine? _updateCreatinine;
  DeleteCreatinine? _deleteCreatinine;

  // Water Intake fields
  WaterIntakeRepositoryImpl? _waterIntakeRepository;
  GetWaterIntake? _getWaterIntake;
  InsertWaterIntake? _insertWaterIntake;
  UpdateWaterIntake? _updateWaterIntake;
  DeleteWaterIntake? _deleteWaterIntake;

  // Family Profile fields
  FamilyProfileRepositoryImpl? _familyProfileRepository;
  GetFamilyProfiles? _getFamilyProfiles;
  InsertFamilyProfile? _insertFamilyProfile;
  UpdateFamilyProfile? _updateFamilyProfile;
  DeleteFamilyProfile? _deleteFamilyProfile;
  SetActiveFamilyProfile? _setActiveFamilyProfile;
  GetActiveFamilyProfile? _getActiveFamilyProfile;

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

  // Blood Sugar UseCase Getters
  GetBloodSugar get getBloodSugar => _getBloodSugar!;
  InsertBloodSugar get insertBloodSugar => _insertBloodSugar!;
  UpdateBloodSugar get updateBloodSugar => _updateBloodSugar!;
  DeleteBloodSugar get deleteBloodSugar => _deleteBloodSugar!;

  // Sleep Record UseCase Getters
  GetSleepRecord get getSleepRecord => _getSleepRecord!;
  InsertSleepRecord get insertSleepRecord => _insertSleepRecord!;
  UpdateSleepRecord get updateSleepRecord => _updateSleepRecord!;
  DeleteSleepRecord get deleteSleepRecord => _deleteSleepRecord!;

  // Step Count UseCase Getters
  GetStepCount get getStepCount => _getStepCount!;
  InsertStepCount get insertStepCount => _insertStepCount!;
  UpdateStepCount get updateStepCount => _updateStepCount!;
  DeleteStepCount get deleteStepCount => _deleteStepCount!;

  // Cholesterol UseCase Getters
  GetCholesterol get getCholesterol => _getCholesterol!;
  InsertCholesterol get insertCholesterol => _insertCholesterol!;
  UpdateCholesterol get updateCholesterol => _updateCholesterol!;
  DeleteCholesterol get deleteCholesterol => _deleteCholesterol!;

  // Creatinine UseCase Getters
  GetCreatinine get getCreatinine => _getCreatinine!;
  InsertCreatinine get insertCreatinine => _insertCreatinine!;
  UpdateCreatinine get updateCreatinine => _updateCreatinine!;
  DeleteCreatinine get deleteCreatinine => _deleteCreatinine!;

  // Water Intake UseCase Getters
  GetWaterIntake get getWaterIntake => _getWaterIntake!;
  InsertWaterIntake get insertWaterIntake => _insertWaterIntake!;
  UpdateWaterIntake get updateWaterIntake => _updateWaterIntake!;
  DeleteWaterIntake get deleteWaterIntake => _deleteWaterIntake!;

  // Family Profile UseCase Getters
  GetFamilyProfiles get getFamilyProfiles => _getFamilyProfiles!;
  InsertFamilyProfile get insertFamilyProfile => _insertFamilyProfile!;
  UpdateFamilyProfile get updateFamilyProfile => _updateFamilyProfile!;
  DeleteFamilyProfile get deleteFamilyProfile => _deleteFamilyProfile!;
  SetActiveFamilyProfile get setActiveFamilyProfile => _setActiveFamilyProfile!;
  GetActiveFamilyProfile get getActiveFamilyProfile => _getActiveFamilyProfile!;

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

    // Blood Sugar
    final bloodSugarDataSource = BloodSugarDataSourceImpl();
    _bloodSugarRepository = BloodSugarRepositoryImpl(bloodSugarDataSource);
    _getBloodSugar = GetBloodSugar(_bloodSugarRepository!);
    _insertBloodSugar = InsertBloodSugar(_bloodSugarRepository!);
    _updateBloodSugar = UpdateBloodSugar(_bloodSugarRepository!);
    _deleteBloodSugar = DeleteBloodSugar(_bloodSugarRepository!);

    // Sleep Record
    final sleepRecordDataSource = SleepRecordDataSourceImpl();
    _sleepRecordRepository = SleepRecordRepositoryImpl(sleepRecordDataSource);
    _getSleepRecord = GetSleepRecord(_sleepRecordRepository!);
    _insertSleepRecord = InsertSleepRecord(_sleepRecordRepository!);
    _updateSleepRecord = UpdateSleepRecord(_sleepRecordRepository!);
    _deleteSleepRecord = DeleteSleepRecord(_sleepRecordRepository!);

    // Step Count
    final stepCountDataSource = StepCountDataSourceImpl();
    _stepCountRepository = StepCountRepositoryImpl(stepCountDataSource);
    _getStepCount = GetStepCount(_stepCountRepository!);
    _insertStepCount = InsertStepCount(_stepCountRepository!);
    _updateStepCount = UpdateStepCount(_stepCountRepository!);
    _deleteStepCount = DeleteStepCount(_stepCountRepository!);

    // Cholesterol
    final cholesterolDataSource = CholesterolDataSourceImpl();
    _cholesterolRepository = CholesterolRepositoryImpl(cholesterolDataSource);
    _getCholesterol = GetCholesterol(_cholesterolRepository!);
    _insertCholesterol = InsertCholesterol(_cholesterolRepository!);
    _updateCholesterol = UpdateCholesterol(_cholesterolRepository!);
    _deleteCholesterol = DeleteCholesterol(_cholesterolRepository!);

    // Creatinine
    final creatinineDataSource = CreatinineDataSourceImpl();
    _creatinineRepository = CreatinineRepositoryImpl(creatinineDataSource);
    _getCreatinine = GetCreatinine(_creatinineRepository!);
    _insertCreatinine = InsertCreatinine(_creatinineRepository!);
    _updateCreatinine = UpdateCreatinine(_creatinineRepository!);
    _deleteCreatinine = DeleteCreatinine(_creatinineRepository!);

    // Water Intake
    final waterIntakeDataSource = WaterIntakeDataSourceImpl();
    _waterIntakeRepository = WaterIntakeRepositoryImpl(dataSource: waterIntakeDataSource);
    _getWaterIntake = GetWaterIntake(_waterIntakeRepository!);
    _insertWaterIntake = InsertWaterIntake(_waterIntakeRepository!);
    _updateWaterIntake = UpdateWaterIntake(_waterIntakeRepository!);
    _deleteWaterIntake = DeleteWaterIntake(_waterIntakeRepository!);

    // Family Profile
    final familyProfileDataSource = FamilyProfileDataSourceImpl();
    _familyProfileRepository = FamilyProfileRepositoryImpl(familyProfileDataSource);
    _getFamilyProfiles = GetFamilyProfiles(_familyProfileRepository!);
    _insertFamilyProfile = InsertFamilyProfile(_familyProfileRepository!);
    _updateFamilyProfile = UpdateFamilyProfile(_familyProfileRepository!);
    _deleteFamilyProfile = DeleteFamilyProfile(_familyProfileRepository!);
    _setActiveFamilyProfile = SetActiveFamilyProfile(_familyProfileRepository!);
    _getActiveFamilyProfile = GetActiveFamilyProfile(_familyProfileRepository!);

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
