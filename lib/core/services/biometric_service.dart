import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUseBiometric() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      final availableBiometrics = await _auth.getAvailableBiometrics();

      return canCheckBiometrics &&
          isDeviceSupported &&
          availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final canUse = await canUseBiometric();

      if (!canUse) {
        return false;
      }

      return _auth.authenticate(
        localizedReason: 'Xác thực vân tay của bạn để vào HealthCare+',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
