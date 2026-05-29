import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'services/analytics/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  try {
    await Firebase.initializeApp();
  } catch (e) {
    runApp(_FirebaseErrorApp(error: e));
    return;
  }

  try {
    await AnalyticsService.instance.initialize();
  } catch (e) {
    debugPrint('Analytics init failed (403 likely = API not enabled in console): $e');
  }

  if (kDebugMode) {
    Bloc.observer = DebugBlocObserver();
  }

  runApp(const App());
}

class _FirebaseErrorApp extends StatelessWidget {
  final Object error;
  const _FirebaseErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                const Text('Connection Failed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Could not connect to Firebase. Check your internet connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 8),
                Text('$error', style: TextStyle(color: Colors.grey[400], fontSize: 12), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await Firebase.initializeApp();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(builder: (_) => const App()),
                        );
                      }
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DebugBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('${bloc.runtimeType} event: $event');
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    debugPrint('${bloc.runtimeType} transition: $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('${bloc.runtimeType} error: $error');
  }
}
