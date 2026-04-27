import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/services/firebase_service.dart';
import 'data/services/research_data_seeder.dart';
import 'presentation/providers/project_provider.dart';
import 'presentation/providers/sprint_provider.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/kpi_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'fake-api-key',
      appId: '1:123456789:android:abcdef',
      messagingSenderId: '123456789',
      projectId: 'demo-no-project',
    ),
  );

  // Connect to local Firebase emulators
  FirebaseService.connectToEmulators();

  // Seed research data on first launch.
  // Idempotency: we check Auth first (unauthenticated) then Firestore after signing in.
  // To re-seed: clear emulator data via the Emulator UI at http://localhost:4000.
  try {
    final auth = FirebaseAuth.instance;
    final db   = FirebaseFirestore.instance;

    // Step 1 — try to sign in with the manager account.
    // If the account doesn't exist yet, the seeder needs to run.
    bool needsSeed = false;
    try {
      await auth.signInWithEmailAndPassword(
        email: 'devendra@agilevision.com',
        password: 'research2026',
      );
      // Signed in — check if Firestore data exists (project + kpi_snapshots)
      final projectCheck = await db.collection('projects').doc('demo_project_1').get();
      if (!projectCheck.exists) {
        needsSeed = true;
      } else {
        // Also check kpi_snapshots — if empty, seeder was blocked by old rules
        final kpiCheck = await db
            .collection('projects')
            .doc('demo_project_1')
            .collection('kpi_snapshots')
            .limit(1)
            .get();
        needsSeed = kpiCheck.docs.isEmpty;
      }
      // ignore: avoid_print
      print('Seeder: auth ok, project exists=${projectCheck.exists}, needsSeed=$needsSeed');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        needsSeed = true;
        // ignore: avoid_print
        print('Seeder: manager account not found — will seed');
      } else {
        // ignore: avoid_print
        print('Seeder: auth check failed (${e.code}) — skipping seed');
      }
    }

    if (needsSeed) {
      // ignore: avoid_print
      print('Seeder: running full seed...');
      await auth.signOut(); // ensure clean state before seeder creates accounts
      final seeder = ResearchDataSeeder(db, auth);
      await seeder.seedAllData();
      // ignore: avoid_print
      print('Seeder: complete ✓');
    } else {
      await auth.signOut(); // sign out so user lands on login screen
    }
  } catch (e) {
    // ignore: avoid_print
    print('Seeder: error — $e');
  }

  runApp(const AgileVisionApp());
}

class AgileVisionApp extends StatelessWidget {
  const AgileVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => SprintProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => KpiProvider()),
      ],
      child: MaterialApp(
        title: 'AgileVision',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
