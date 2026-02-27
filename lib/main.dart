import 'package:doctor_care/core/pages/apptheme.dart';
import 'package:doctor_care/firebase_options.dart';
import 'package:doctor_care/injection_container.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/bloc/themestate/themestate_cubit.dart';
import 'package:doctor_care/presentation/bloc/themestate/themestate_state.dart';
import 'package:doctor_care/presentation/pages/screens/HbA1c/hba1c_screen.dart';
import 'package:doctor_care/presentation/pages/screens/NavigationBar/navigationbar.dart';
import 'package:doctor_care/presentation/pages/screens/Spo2HeartRate/spo2_heartrate_screen.dart';
import 'package:doctor_care/presentation/pages/screens/Temperature/temperature_screen.dart';
import 'package:doctor_care/presentation/pages/screens/bloodPressure/blood_pressure_screen.dart';
import 'package:doctor_care/presentation/pages/screens/BMIWeight/bmi_weight_screen.dart';
import 'package:doctor_care/presentation/pages/screens/WaterIntake/water_intake_screen.dart';
import 'package:doctor_care/presentation/pages/screens/health_overview/health_overview_screen.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:doctor_care/presentation/bloc/BMIWeight/bmi_weight_bloc.dart';
import 'package:doctor_care/presentation/bloc/water_intake/water_intake_bloc.dart';
import 'package:doctor_care/presentation/bloc/blood_sugar/blood_sugar_cubit.dart';
import 'package:doctor_care/presentation/bloc/sleep_record/sleep_record_cubit.dart';
import 'package:doctor_care/presentation/bloc/step_count/step_count_cubit.dart';
import 'package:doctor_care/presentation/bloc/cholesterol/cholesterol_cubit.dart';
import 'package:doctor_care/presentation/bloc/family_profile/family_profile_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/BloodSugar/blood_sugar_screen.dart';
import 'package:doctor_care/presentation/pages/screens/SleepRecord/sleep_record_screen.dart';
import 'package:doctor_care/presentation/pages/screens/StepCount/step_count_screen.dart';
import 'package:doctor_care/presentation/pages/screens/Cholesterol/cholesterol_screen.dart';
import 'package:doctor_care/presentation/pages/screens/FamilyProfile/family_profile_screen.dart';
import 'package:doctor_care/presentation/pages/screens/auth/login_screen.dart';
import 'package:doctor_care/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/admin/admin_panel_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('vi', null);

  try {
    await InjectionContainer().init();
  } catch (e) {
    debugPrint('❌ InjectionContainer init failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final di = InjectionContainer();

    return MultiBlocProvider(
      providers: [
        // ✅ Theme Cubit
        BlocProvider(create: (context) => ThemeCubit()),

        // Auth
        BlocProvider(
          create: (context) => AuthBloc(
            signInUseCase: di.signInUseCase,
            signInWithGoogleUseCase: di.signInWithGoogleUseCase,
            signUpUseCase: di.signUpUseCase,
            signOutUseCase: di.signOutUseCase,
            checkAuthStatusUseCase: di.checkAuthStatusUseCase,
            resetPasswordUseCase: di.resetPasswordUseCase,
          ),
        ),

        // HbA1c
        BlocProvider(
          create: (context) => Hba1cCubit(
            di.getHba1c,
            di.insertHba1c,
            di.updateHba1c,
            di.deleteHba1c,
          ),
        ),

        // huyết áp
        BlocProvider(
          create: (context) => BloodPressureCubit(
            di.getBloodPressure,
            di.insertBloodPressure,
            di.updateBloodPressure,
            di.deleteBloodPressure,
          ),
        ),

        // nhiệt độ
        BlocProvider(
          create: (context) => TemperatureCubit(
            di.getTemperature,
            di.insertTemperature,
            di.updateTemperature,
            di.deleteTemperature,
          ),
        ),

        // SpO2
        BlocProvider(
          create: (context) => Spo2heartrateBloc(
            getSpo2heartrate: di.getSpo2heartrate,
            insertSpo2heartrate: di.insertSpo2heartrate,
            updateSpo2heartrate: di.updateSpo2heartrate,
            deleteSpo2heartrate: di.deleteSpo2heartrate,
          ),
        ),

        // BMI
        BlocProvider(
          create: (context) => BMIWeightBloc(
            getBMIWeight: di.getBMIWeight,
            insertBmiweight: di.insertBmiweight,
            updateBmiWeight: di.updateBmiWeight,
            deleteBmiweight: di.deleteBmiweight,
          ),
        ),

        // Water Intake
        BlocProvider(create: (context) => WaterIntakeBloc(di.dbHelper)),

        // Blood Sugar
        BlocProvider(
          create: (context) => BloodSugarCubit(
            di.getBloodSugar,
            di.insertBloodSugar,
            di.updateBloodSugar,
            di.deleteBloodSugar,
          ),
        ),

        // Sleep Record
        BlocProvider(
          create: (context) => SleepRecordCubit(
            di.getSleepRecord,
            di.insertSleepRecord,
            di.updateSleepRecord,
            di.deleteSleepRecord,
          ),
        ),

        // Step Count
        BlocProvider(
          create: (context) => StepCountCubit(
            di.getStepCount,
            di.insertStepCount,
            di.updateStepCount,
            di.deleteStepCount,
          ),
        ),

        // Cholesterol
        BlocProvider(
          create: (context) => CholesterolCubit(
            di.getCholesterol,
            di.insertCholesterol,
            di.updateCholesterol,
            di.deleteCholesterol,
          ),
        ),

        // Meal Analysis
        BlocProvider(create: (context) => di.mealAnalysisBloc),

        // Family Profile
        BlocProvider(
          create: (context) => FamilyProfileCubit(
            di.getFamilyProfiles,
            di.insertFamilyProfile,
            di.updateFamilyProfile,
            di.deleteFamilyProfile,
            di.setActiveFamilyProfile,
            di.getActiveFamilyProfile,
          )..loadProfiles(),
        ),
      ],

      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Doctor Care",

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            navigatorKey: navigatorKey,
            builder: (context, child) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is Unauthenticated) {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  }
                },
                child: child!,
              );
            },

            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  // Đảm bảo hồ sơ "Bản thân" tồn tại khi mở app
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<FamilyProfileCubit>().ensureSelfProfile(
                      name: state.user.fullName ?? state.user.email.split('@').first,
                      gender: state.user.gender,
                      bloodType: state.user.bloodType,
                      height: state.user.height,
                      weight: state.user.weight,
                      dateOfBirth: state.user.dateOfBirth,
                    );
                  });
                  // Admin → admin panel, Patient → navigation
                  if (state.role == 'admin') {
                    return const AdminPanelScreen();
                  }
                  return const Navigationbar();
                }
                return const Splash();
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/navigation': (context) => const Navigationbar(),
              '/admin-panel': (context) => const AdminPanelScreen(),
              '/health-overview': (context) => const HealthOverviewScreen(),
              '/bloodpressure': (context) => const BloodPressureScreen(),
              '/hba1c': (context) => const Hba1cScreen(),
              '/temperature': (context) => const TemperatureScreen(),
              '/spo2heart': (context) => const Spo2HeartRateScreen(),
              '/bmiweight': (context) => const BmiWeightScreen(),
              '/waterintake': (context) => const WaterIntakeScreen(),
              '/bloodsugar': (context) => const BloodSugarScreen(),
              '/sleep': (context) => const SleepRecordScreen(),
              '/stepcounter': (context) => const StepCountScreen(),
              '/cholesterol': (context) => const CholesterolScreen(),
              '/familyprofile': (context) => const FamilyProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
