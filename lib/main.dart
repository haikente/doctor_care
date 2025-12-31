//import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/injection_container.dart';
import 'package:doctor_care/presentation/bloc/blood_pressure/blood_pressure_cubit.dart';
import 'package:doctor_care/presentation/bloc/hba1c/hba1c_cubit.dart';
import 'package:doctor_care/presentation/bloc/temperature/temperature_cubit.dart';
import 'package:doctor_care/presentation/pages/screens/HbA1c/hba1c_screen.dart';
import 'package:doctor_care/presentation/pages/screens/NavigationBar/navigationbar.dart';
import 'package:doctor_care/presentation/pages/screens/Temperature/temperature_screen.dart';
import 'package:doctor_care/presentation/pages/screens/bloodPressure/blood_pressure_screen.dart';
import 'package:doctor_care/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await initializeDateFormatting('vi_VN', null);
  await InjectionContainer().init();
  //await DbHelper.instance.deleteDatabase(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
     final di = InjectionContainer();
    return MultiBlocProvider(
      providers: [

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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Docter App",
        theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.blue.shade600,
            selectionColor: Colors.blue.withOpacity(0.3),
            selectionHandleColor: Colors.blue.shade600
          ),
          scaffoldBackgroundColor: Colors.white,
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          fontFamily: 'Rubik'
        ),
        home: const Splash(),
        routes: {
          '/navigation': (context) => const Navigationbar(),
          '/bloodpressure': (context) => const BloodPressureScreen(),
          '/hba1c': (context) => const Hba1cScreen(),
          '/temperature': (context) => const TemperatureScreen(),
        },
      ),
    );
  }
}