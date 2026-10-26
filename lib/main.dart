import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/state/academy_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AcademyStore();
  await store.load();
  runApp(AiocybApp(store: store));
}
