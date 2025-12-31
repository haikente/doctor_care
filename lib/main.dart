import 'package:doctor_care/core/pages/apptheme.dart';
import 'package:doctor_care/injection_container.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/bloc/themestate_cubit.dart';
import 'package:doctor_care/presentation/bloc/themestate_state.dart';
import 'package:doctor_care/presentation/pages/screens/HbA1c/hba1c_screen.dart';
import 'package:doctor_care/presentation/pages/screens/NavigationBar/navigationbar.dart';
import 'package:doctor_care/presentation/pages/screens/Temperature/temperature_screen.dart';
import 'package:doctor_care/presentation/pages/screens/bloodPressure/blood_pressure_screen.dart';
import 'package:doctor_care/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

        // Health Data Cubits
        BlocProvider(
          create: (context) => Hba1cCubit(
            di.getHba1c,
            di.insertHba1c,
            di.updateHba1c,
            di.deleteHba1c,
          ),
        ),

        BlocProvider(
          create: (context) => BloodPressureCubit(
            di.getBloodPressure,
            di.insertBloodPressure,
            di.updateBloodPressure,
            di.deleteBloodPressure,
          ),
        ),

        BlocProvider(
          create: (context) => TemperatureCubit(
            di.getTemperature,
            di.insertTemperature,
            di.updateTemperature,
            di.deleteTemperature,
          ),
        ),
      ],
      
      // ✅ Wrap MaterialApp with BlocBuilder
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Doctor Care",
            
            // ✅ Apply dynamic theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            
            home: const Splash(),
            routes: {
              '/navigation': (context) => const Navigationbar(),
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