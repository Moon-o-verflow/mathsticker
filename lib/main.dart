import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';
import 'src/features/ads/ad_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdManager().initialize();

  runApp(
    const ProviderScope(
      child: MathStickerApp(),
    ),
  );
}
