import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/modules/home/services/biometrics_service.dart';
import 'app/modules/home/services/db_service.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  await Get.putAsync<DbService>(() => DbService().init());

  Get.lazyPut(() => BiometricsService(Get.find()));

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
