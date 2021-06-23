import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DbService extends GetxService {
  final _box = GetStorage();

  late RxBool biometricsEnabled;
  late RxBool showBiometricsDialog;

  Future<DbService> init() async {
    super.onInit();
    await GetStorage.init();

    _setupBiometricsEnabled();

    _setupShowBiometricsDialog();

    return this;
  }

  bool _getBoolValue(String key, {bool defaultValue = false}) {
    var rawValue = _box.read(key);
    if (rawValue == null) {
      return defaultValue;
    } else if (rawValue == true.toString()) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _setBoolVal(bool value, String key) async {
    try {
      await _box.write(key, value.toString());
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> _watchForBoolValueChanges(RxBool val, String key) async {
    ever<bool>(val, (val) async {
      try {
        await _setBoolVal(val, key);
      } catch (e) {
        print(e);
      }
    });
  }

  Future<void> _setupBiometricsEnabled() async {
    biometricsEnabled = RxBool(_getBoolValue('BIOMETRICS_ENABLED'));

    await _watchForBoolValueChanges(biometricsEnabled, 'BIOMETRICS_ENABLED');
  }

  Future<void> _setupShowBiometricsDialog() async {
    showBiometricsDialog = RxBool(_getBoolValue(
      'SHOW_BIOMETRICS_DIALOG',
      defaultValue: true,
    ));

    await _watchForBoolValueChanges(
        showBiometricsDialog, 'SHOW_BIOMETRICS_DIALOG');
  }

  Future<void> clearBiometricsData() async {
    await _box.remove('BIOMETRICS_ENABLED');
    await _box.remove('SHOW_BIOMETRICS_DIALOG');
  }
}
