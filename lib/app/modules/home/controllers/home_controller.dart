import 'package:biometric_test/app/modules/home/services/biometrics_service.dart';
import 'package:biometric_test/app/modules/home/services/db_service.dart';
import 'package:faker/faker.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final BiometricsService biometricsService;
  final DbService dbService;

  final RxString token = RxString('initial');

  HomeController({
    required this.biometricsService,
    required this.dbService,
  });

  RxBool get biometricsEnabled => dbService.biometricsEnabled;

  RxBool get showBiometricsDialog => dbService.showBiometricsDialog;

  @override
  Future<void> onReady() async {
    super.onReady();

    var canAuthenticate = await biometricsService.checkAuthenticate();

    if (canAuthenticate) {
      var val = await biometricsService.requestBiometrics();

      if (val != null) {
        token.value = val;
      }
    }
  }

  Future<void> getStoredValue() async {
    var value = await biometricsService.readValidationToken();

    if (value != null) {
      token.value = value;
    }
  }

  void toggleEnableBiometrics(bool? val) {
    if (val != null) {
      dbService.biometricsEnabled(val);
    }
  }

  void toggleShowBiometricsDialog(bool? val) {
    if (val != null) {
      dbService.showBiometricsDialog(val);
    }
  }

  Future<void> generateNewToken() async {
    token.value = Faker().internet.email();
    await biometricsService.deleteValidationToken();
  }
}
