import 'package:biometric_storage/biometric_storage.dart';
import 'package:biometric_test/app/modules/home/services/db_service.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BiometricsService {
  final DbService dbService;

  BiometricsService(this.dbService);

  Future<bool> checkAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();
    print('checked if authentication was possible: $response');

    final supportsAuthenticated = response == CanAuthenticateResponse.success ||
        response == CanAuthenticateResponse.statusUnknown;
    return supportsAuthenticated;
  }

  RxBool get biometricsEnabled => dbService.biometricsEnabled;

  Future<bool> get canShowEnableBiometricsDialog async {
    var supportsAuthentication = await checkAuthenticate();

    return supportsAuthentication && (dbService.showBiometricsDialog.value);
  }

  Future<String?> readValidationToken() async {
    BiometricStorageFile value = await _getBiometricsFile();

    return value.read();
  }

  Future<void> deleteValidationToken() async {
    BiometricStorageFile value = await _getBiometricsFile();
    await dbService.clearBiometricsData();
    return value.delete();
  }

  Future<void> storeValidationToken(String val) async {
    BiometricStorageFile value = await _getBiometricsFile();

    return value.write(val);
  }

  Future<BiometricStorageFile> _getBiometricsFile() async {
    var value = await BiometricStorage().getStorage(
      '_customPrompt',
      options:
          StorageFileInitOptions(authenticationValidityDurationSeconds: 30),
      androidPromptInfo: const AndroidPromptInfo(title: 'Sign In'),
    );
    return value;
  }

  Future<String?> showEnableBiometricsDialog() async {
    final faker = Faker();
    String? token;

    await Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Enable Sign-In with biometrics? (This can be changed in settings)'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(primary: Colors.redAccent),
                    onPressed: () {
                      Get.until((route) => Get.isDialogOpen == false);
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 20),
                  TextButton(
                    style: TextButton.styleFrom(primary: Colors.blueAccent),
                    onPressed: () {
                      token = faker.internet.email();
                      Get.until((route) => Get.isDialogOpen == false);
                    },
                    child: Text('Enable'),
                  ),
                ],
              ),
              SizedBox(width: 20),
              ObxValue<RxBool>(
                (value) {
                  return CheckboxListTile(
                    value: value.value,
                    onChanged: dbService.showBiometricsDialog,
                    title: Text('Keep seeing this dialog.'),
                  );
                },
                dbService.showBiometricsDialog,
              ),
            ],
          ),
        ),
      ),
    );

    return token;
  }

  Future<String?> requestBiometrics() async {
    String? token;
    if (biometricsEnabled.isTrue) {
      token = await readValidationToken() ?? 'initial';
    } else {
      var val = await canShowEnableBiometricsDialog;

      if (val) {
        var newToken = await showEnableBiometricsDialog();
        token = newToken;
        if (token != null) {
          await storeValidationToken(token);
        }
      }
    }

    return token;
  }
}
