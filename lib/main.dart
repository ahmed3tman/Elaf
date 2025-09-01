import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jalees/my_app.dart';
import 'package:jalees/features/quran/data/page_mapping_repository.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash (with bottom label) visible until we finish init.
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Start required initialization and ensure a minimal splash duration.
  final sw = Stopwatch()..start();
  try {
    await PageMappingRepository.ensureLoaded();
  } catch (_) {
    // ignore non-fatal preload errors; app can still start
  }
  const minSplashMs = 900; // keep splash visible for at least ~0.9s
  final remaining = minSplashMs - sw.elapsedMilliseconds;
  if (remaining > 0) {
    await Future.delayed(Duration(milliseconds: remaining));
  }

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}
