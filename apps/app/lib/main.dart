import 'package:flutter/material.dart';

import 'app.dart';
import 'services/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushService.instance.initialize();
  runApp(const CouponApp());
}
