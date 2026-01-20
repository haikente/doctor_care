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
import 'package:doctor_care/presentation/pages/screens/Temperature/temperature_screen.dart';
import 'package:doctor_care/presentation/pages/screens/bloodPressure/blood_pressure_screen.dart';
import 'package:doctor_care/presentation/bloc/Spo2heartrate/spo2heartrate_bloc.dart';
import 'package:doctor_care/presentation/bloc/BMIWeight/bmi_weight_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_care/presentation/bloc/auth/auth_bloc.dart';
import 'package:doctor_care/presentation/pages/screens/auth/login_screen.dart';
import 'package:doctor_care/presentation/pages/screens/admin/admin_panel_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await InjectionContainer().init();
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
                  return const Navigationbar();
                }
                // ✅ Mặc định luôn hiển thị Login Screen
                return const LoginScreen();
              },
            ),
            routes: {
              '/navigation': (context) => const Navigationbar(),
              '/admin-panel': (context) => const AdminPanelScreen(),
              '/bloodpressure': (context) => const BloodPressureScreen(),
              '/hba1c': (context) => const Hba1cScreen(),
              '/temperature': (context) => const TemperatureScreen(),
            },
          );
        },
      ),
    );
  }
}
