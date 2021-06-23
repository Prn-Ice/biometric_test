import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeView'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Text(
                'Stored token: ${controller.token}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 80),
            ObxValue<RxBool>(
              (value) {
                return CheckboxListTile(
                  value: value.value,
                  onChanged: (val) => controller.toggleEnableBiometrics(val),
                  title: Text('Enable biometrics'),
                );
              },
              controller.biometricsEnabled,
            ),
            SizedBox(height: 20),
            ObxValue<RxBool>(
              (value) {
                return CheckboxListTile(
                  value: value.value,
                  onChanged: (val) => controller.showBiometricsDialog(val),
                  title: Text('Show biometrics dialog'),
                );
              },
              controller.showBiometricsDialog,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.generateNewToken,
              child: Text('Generate new token'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.getStoredValue,
              child: Text('Read saved token'),
            ),
          ],
        ),
      ),
    );
  }
}
