// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'seeder_devendra.dart';
import 'seeder_roshan.dart';
import 'seeder_shambhu.dart';
import 'seeder_shiva.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AgileVision — Master Research Data Seeder
//
// Architecture (professional separation of concerns):
//   ResearchDataSeeder       ← you are here (orchestrator)
//   ├── SeederDevendra       ← Schedule: sprints, kpi_snapshots, MC, ES, WMA
//   ├── SeederRoshan         ← Cost: cost_snapshots, PMB, sensitivity, MAPE
//   ├── SeederShambhu        ← HCI: Nielsen, TTI, Gestalt, Sensemaking, UCD…
//   └── SeederShiva          ← Infra: RBAC, CAP, ATAM, CQRS, event log…
//
// Seeding philosophy:
//   • Auth / Users / Project / Tasks are owned by this orchestrator
//   • Each member seeder owns its own collections and evaluation documents
//   • All operations are idempotent — safe to call on every app launch
//   • To re-seed: clear Emulator UI at http://localhost:4000
//
// UWS MSc Masters Research Project 2025-26
// Members: Devendra Poudel · Roshan Sharma Chapagain · Shambhu Chapagain · Shiva KC
// Supervisor: Abdallah Abu Madi
// ══════════════════════════════════════════════════════════════════════════════

class ResearchDataSeeder {
  final FirebaseFirestore _db;
  final FirebaseAuth      _auth;
  static const String _projectId = 'demo_project_1';

  String _managerUid   = ''; // devendra@agilevision.com (manager role)
  String _developerUid = ''; // developer@agilevision.com (generic)

  ResearchDataSeeder(this._db, this._auth);

  // ── Entry point ────────────────────────────────────────────────────────────
  Future<void> seedAllData() async {
    print('');
    print('╔══════════════════════════════════════════════════════════╗');
    print('║  AgileVision — Research Data Seeder                     ║');
    print('║  UWS MSc Masters Research Project 2025-26               ║');
    print('╚══════════════════════════════════════════════════════════╝');

    // Phase 1 — Shared foundation (must complete before member seeders)
    await _seedAuthAccounts();
    await _seedUsers();
    await _seedProject();
    await _seedTasks();

    // Phase 2 — Member seeders (independent, called in sequence)
    await SeederDevendra(_db).seed();
    await SeederRoshan(_db, _managerUid).seed();
    await SeederShambhu(_db).seed();
    await SeederShiva(_db).seed();

    print('');
    print('╔══════════════════════════════════════════════════════════╗');
    print('║  Seeding complete — all research data ready              ║');
    print('║  Dashboard will load from kpi_snapshots in real time    ║');
    print('╚══════════════════════════════════════════════════════════╝');
    print('');

    await _auth.signOut();
  }

  // ── Auth accounts + User docs ──────────────────────────────────────────────
  // Creates each Firebase Auth account then immediately writes that user's
  // Firestore doc while signed in as them — satisfying the RBAC rule:
  //   allow write: if isAuthenticated() && request.auth.uid == userId
  // Finally signs in as Devendra (manager) so remaining Firestore writes pass.
  Future<void> _seedAuthAccounts() async {
    print('');
    print('── Auth + Users: Seeding accounts and user documents ──');

    final createdAt = Timestamp.fromDate(DateTime(2026, 1, 1));

    // (email, password, role, name, specialisation, researchComponent, bannerId)
    final accounts = [
      ('devendra@agilevision.com',  'research2026', 'manager',   'Devendra Poudel',         'Schedule Prediction and Algorithmic Forecasting', 'Schedule Prediction Engine',            'B01812596'),
      ('roshan@agilevision.com',    'research2026', 'developer', 'Roshan Sharma Chapagain', 'Cost Performance and Financial Engineering',      'Cost Performance Engine',               'B01813208'),
      ('shambhu@agilevision.com',   'research2026', 'developer', 'Shambhu Chapagain',       'HCI and Mobile Interface Design',                'Mobile UI and HCI Research',            'B01813880'),
      ('shiva@agilevision.com',     'research2026', 'developer', 'Shiva KC',                'Cloud Infrastructure and Data Security',          'Cloud Data Infrastructure and Security','B01803951'),
      ('developer@agilevision.com', 'research2026', 'developer', 'Developer Account',       'General Development',                            '',                                      ''),
    ];

    for (final (email, password, role, name, specialisation, researchComp, bannerId) in accounts) {
      String uid;
      try {
        final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        uid = cred.user!.uid;
        print('  Created: $email → $uid');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
          uid = cred.user!.uid;
          print('  Exists:  $email → $uid');
        } else {
          print('  ERROR creating $email: ${e.code}');
          rethrow;
        }
      }

      // Store UIDs for later use
      if (email == 'devendra@agilevision.com')  _managerUid   = uid;
      if (email == 'developer@agilevision.com') _developerUid = uid;

      // Write this user's Firestore doc immediately while signed in as them.
      // This satisfies: allow write: if isAuthenticated() && request.auth.uid == userId
      final userDoc = _db.collection('users').doc(uid);
      final existing = await userDoc.get();
      if (!existing.exists) {
        final data = <String, dynamic>{
          'uid': uid, 'name': name, 'email': email,
          'role': role, 'specialisation': specialisation,
          'createdAt': createdAt,
        };
        if (researchComp.isNotEmpty) data['researchComponent'] = researchComp;
        if (bannerId.isNotEmpty)     data['bannerId'] = bannerId;
        await userDoc.set(data);
        print('    User doc written: $email ($role)');
      } else {
        print('    User doc exists: $email');
      }
    }

    // Sign in as Devendra (manager) — all remaining Firestore writes need
    // isAuthenticated() + isManager() for projects/sprints/tasks collections.
    final managerCred = await _auth.signInWithEmailAndPassword(
        email: 'devendra@agilevision.com', password: 'research2026');
    _managerUid = managerCred.user!.uid;
    print('  Signed in as manager: devendra@agilevision.com ($_managerUid)');
    print('  All ${accounts.length} accounts + user docs ready ✓');
  }

  // ── Users — no-op (handled inline in _seedAuthAccounts) ───────────────────
  Future<void> _seedUsers() async {
    // User docs are written per-account inside _seedAuthAccounts while each
    // user is signed in, to satisfy the RBAC own-doc write rule.
    // This method is kept for structural clarity but does nothing extra.
    print('── Users: already seeded inline with auth accounts ✓');
  }

  // ── Project ────────────────────────────────────────────────────────────────
  Future<void> _seedProject() async {
    print('── Project: Seeding project document ──');
    final doc = await _db.collection('projects').doc(_projectId).get();
    if (doc.exists) { print('  demo_project_1 already exists — skipping'); return; }

    await _db.collection('projects').doc(_projectId).set({
      'name': 'AgileVision Platform Development',
      'description':
          'Cloud-based mobile application for real-time monitoring of Agile project schedule and '
          'cost performance. MSc Masters Research Project, University of the West of Scotland 2025-26. '
          'Design Science Research methodology (Peffers et al., 2007).',
      'status': 'active',
      // totalStoryPoints = sum of all task story points across sprints 1–12
      // Sprints 1–11 historic tasks: 18+22+20+11+15+19+21+9+16+20+13 = 184 pts
      // Sprint 12 active tasks: 120 pts → Grand total = 304 pts
      // BAC denominator uses this as the full project scope baseline
      'bac': 50000.0, 'totalStoryPoints': 304, 'totalSprints': 12,
      'sprintLengthDays': 14, 'teamSize': 4, 'methodology': 'Scrum',
      'researchFramework': 'Design Science Research (Peffers et al., 2007)',
      'startDate':  Timestamp.fromDate(DateTime(2026, 1,  5)),
      'endDate':    Timestamp.fromDate(DateTime(2026, 3, 27)),
      'createdBy':  _managerUid,
      'createdAt':  Timestamp.fromDate(DateTime(2026, 1, 5)),
    });
    print('  demo_project_1 created ✓');
  }

  // ── Tasks ──────────────────────────────────────────────────────────────────
  // Represents the actual AgileVision development work across sprints 1–12.
  // Sprint 12 (active) tasks represent the current state of the board.
  // Historic tasks from sprints 1–7 provide burndown and velocity history.
  Future<void> _seedTasks() async {
    print('── Tasks: Seeding task documents ──');
    final check = await _db.collection('projects').doc(_projectId)
        .collection('tasks').limit(1).get();
    if (check.docs.isNotEmpty) { print('  Tasks already seeded — skipping'); return; }

    final now = DateTime.now();

    // Sprint 12 active sprint tasks — assigned by research component
    final sprint12Tasks = <(String, String, int, String, String, String, String, DateTime?)>[
      // Shiva — Infrastructure tasks
      ('task_s12_shiva_1',   'Deploy Firestore and configure emulator connectivity',      5, 'done',        'team_shiva_001',    'sprint_12', 'Infrastructure',   now.subtract(const Duration(days: 5))),
      ('task_s12_shiva_2',   'Implement Firestore RBAC security rules (15 test scenarios)',5, 'done',        'team_shiva_001',    'sprint_12', 'Infrastructure',   now.subtract(const Duration(days: 4))),
      ('task_s12_shiva_3',   'Design and validate hierarchical NoSQL document schema',     5, 'done',        'team_shiva_001',    'sprint_12', 'Infrastructure',   now.subtract(const Duration(days: 3))),
      ('task_s12_shiva_4',   'Implement CDC Cloud Functions (onTaskStatusChange)',         8, 'done',        'team_shiva_001',    'sprint_12', 'Infrastructure',   now.subtract(const Duration(days: 2))),
      ('task_s12_shiva_5',   'Run RBAC security audit and document ATAM analysis',        5, 'in_progress', 'team_shiva_001',    'sprint_12', 'Infrastructure',   null),
      // Devendra — Schedule tasks
      ('task_s12_dev_1',     'Implement WMA velocity algorithm with [3,2,1] weights',     8, 'done',        'team_devendra_001', 'sprint_12', 'Schedule',         now.subtract(const Duration(days: 6))),
      ('task_s12_dev_2',     'Build Monte Carlo simulation engine (1000 iterations)',      8, 'done',        'team_devendra_001', 'sprint_12', 'Schedule',         now.subtract(const Duration(days: 5))),
      ('task_s12_dev_3',     'Implement Earned Schedule (ES, SVt, SPIt) metrics',         5, 'done',        'team_devendra_001', 'sprint_12', 'Schedule',         now.subtract(const Duration(days: 4))),
      ('task_s12_dev_4',     'Build sprint burndown chart widget',                         5, 'done',        'team_devendra_001', 'sprint_12', 'Schedule',         now.subtract(const Duration(days: 3))),
      ('task_s12_dev_5',     'Build Schedule screen — Cone of Uncertainty visualisation', 8, 'in_progress', 'team_devendra_001', 'sprint_12', 'Schedule',         null),

      // Roshan — Cost tasks
      ('task_s12_ros_1',     'Implement AgileEVM financial calculations engine',           8, 'done',        'team_roshan_001',   'sprint_12', 'Cost',             now.subtract(const Duration(days: 6))),
      ('task_s12_ros_2',     'Build Data Validation Layer for outlier detection',          5, 'done',        'team_roshan_001',   'sprint_12', 'Cost',             now.subtract(const Duration(days: 5))),
      ('task_s12_ros_3',     'Implement sensitivity analysis engine (7 scenarios)',        5, 'done',        'team_roshan_001',   'sprint_12', 'Cost',             now.subtract(const Duration(days: 4))),
      ('task_s12_ros_4',     'Build CPI trend and cost variance charts',                   5, 'done',        'team_roshan_001',   'sprint_12', 'Cost',             now.subtract(const Duration(days: 3))),
      ('task_s12_ros_5',     'Build Cost screen — Optimism Bias comparison chart',        8, 'in_progress', 'team_roshan_001',   'sprint_12', 'Cost',             null),

      // Shambhu — UI/HCI tasks
      ('task_s12_sha_1',     'Design and implement AppColors design system',               3, 'done',        'team_shambhu_001',  'sprint_12', 'UI/HCI',           now.subtract(const Duration(days: 7))),
      ('task_s12_sha_2',     'Build Dashboard Information Radiator (4 KPI cards)',         8, 'done',        'team_shambhu_001',  'sprint_12', 'UI/HCI',           now.subtract(const Duration(days: 5))),
      ('task_s12_sha_3',     'Build HCI Evaluation dedicated screen',                      8, 'backlog',     'team_shambhu_001',  'sprint_12', 'UI/HCI',           null),
      ('task_s12_sha_4',     'Implement TTI benchmarking tracker widget',                  5, 'backlog',     'team_shambhu_001',  'sprint_12', 'UI/HCI',           null),
      ('task_s12_sha_5',     'Final UI polish — Gestalt compliance review',                3, 'backlog',     'team_shambhu_001',  'sprint_12', 'UI/HCI',           null),
    ];

    // Historical tasks from sprints 1–7 (completed — populate burndown history)
    // Typed as List<(String, String, int, String, String, String, DateTime)> — no nullable fields
    // Historic tasks for sprints 1–11 (all completed — status: done)
    // Story points per sprint sum EXACTLY to the sprint velocity field.
    // This ensures Cloud Function EV calculation matches sprint velocity data.
    // Sprint velocities: [18, 22, 20, 11, 15, 19, 21, 9, 16, 20, 13]
    final historicTasks = <(String, String, int, String, String, String, DateTime)>[
      // ── Sprint 1 — velocity 18 pts ──────────────────────────────────────────
      // Scope: Core infrastructure setup. Slight underperformance (vel=18 vs plan=20).
      ('hist_t1_1', 'Set up Firebase project and configure emulator suite',       5, 'done', _managerUid,   'sprint_1', now.subtract(const Duration(days: 90))),
      ('hist_t1_2', 'Implement Firebase Auth with RBAC role assignment',          5, 'done', _managerUid,   'sprint_1', now.subtract(const Duration(days: 89))),
      ('hist_t1_3', 'Design Firestore NoSQL hierarchical document schema',        5, 'done', _developerUid, 'sprint_1', now.subtract(const Duration(days: 88))),
      ('hist_t1_4', 'Build SplashScreen and LoginScreen with form validation',    3, 'done', _developerUid, 'sprint_1', now.subtract(const Duration(days: 87))),
      // ── Sprint 2 — velocity 22 pts ──────────────────────────────────────────
      // Scope: Providers and dashboard shell. High performance sprint.
      ('hist_t2_1', 'Implement ProjectProvider with Firestore stream binding',    5, 'done', _developerUid, 'sprint_2', now.subtract(const Duration(days: 76))),
      ('hist_t2_2', 'Implement SprintProvider with active sprint detection',      5, 'done', _developerUid, 'sprint_2', now.subtract(const Duration(days: 75))),
      ('hist_t2_3', 'Build DashboardScreen KPI metric card grid',                 5, 'done', _developerUid, 'sprint_2', now.subtract(const Duration(days: 74))),
      ('hist_t2_4', 'Implement TaskProvider with real-time task stream',          4, 'done', _managerUid,   'sprint_2', now.subtract(const Duration(days: 73))),
      ('hist_t2_5', 'Build bottom navigation with 5 screen tabs',                 3, 'done', _developerUid, 'sprint_2', now.subtract(const Duration(days: 72))),
      // ── Sprint 3 — velocity 20 pts ──────────────────────────────────────────
      // Scope: Schedule engine. Stable sprint — exactly on target.
      ('hist_t3_1', 'Implement WMA velocity algorithm with [3,2,1] weights',      8, 'done', _managerUid,   'sprint_3', now.subtract(const Duration(days: 62))),
      ('hist_t3_2', 'Build Earned Schedule (ES, SVt, SPIt) calculation module',   5, 'done', _managerUid,   'sprint_3', now.subtract(const Duration(days: 61))),
      ('hist_t3_3', 'Build sprint burndown chart widget (fl_chart)',               4, 'done', _developerUid, 'sprint_3', now.subtract(const Duration(days: 60))),
      ('hist_t3_4', 'Implement ScheduleScreen with velocity trend chart',          3, 'done', _developerUid, 'sprint_3', now.subtract(const Duration(days: 59))),
      // ── Sprint 4 — velocity 11 pts ──────────────────────────────────────────
      // Scope: Cost engine. SCOPE CREEP — client added 9 pts mid-sprint → vel=11.
      ('hist_t4_1', 'Implement AgileEVM core: EV, PV, AC, SV, SPI calculation',  5, 'done', _managerUid,   'sprint_4', now.subtract(const Duration(days: 48))),
      ('hist_t4_2', 'Implement CPI, EAC, ETC, TCPI financial engine',             3, 'done', _managerUid,   'sprint_4', now.subtract(const Duration(days: 47))),
      ('hist_t4_3', 'Scope creep: integrate 9-point client-requested features',   3, 'done', _developerUid, 'sprint_4', now.subtract(const Duration(days: 46))),
      // ── Sprint 5 — velocity 15 pts ──────────────────────────────────────────
      // Scope: Partial recovery from scope creep.
      ('hist_t5_1', 'Build CostScreen with AgileEVM metrics display',             5, 'done', _developerUid, 'sprint_5', now.subtract(const Duration(days: 34))),
      ('hist_t5_2', 'Implement CPI trend chart and cost variance bar chart',      5, 'done', _developerUid, 'sprint_5', now.subtract(const Duration(days: 33))),
      ('hist_t5_3', 'Build budget consumption progress bar widget',               3, 'done', _managerUid,   'sprint_5', now.subtract(const Duration(days: 32))),
      ('hist_t5_4', 'Implement KpiSnapshotModel and KpiRepository',              2, 'done', _developerUid, 'sprint_5', now.subtract(const Duration(days: 31))),
      // ── Sprint 6 — velocity 19 pts ──────────────────────────────────────────
      // Scope: Infrastructure + HCI. Recovery sprint — velocity improving.
      ('hist_t6_1', 'Implement InfrastructureScreen with latency benchmarks',     5, 'done', _developerUid, 'sprint_6', now.subtract(const Duration(days: 20))),
      ('hist_t6_2', 'Build live Firestore read/write/consistency latency tests',  5, 'done', _managerUid,   'sprint_6', now.subtract(const Duration(days: 19))),
      ('hist_t6_3', 'Implement Nielsen 10-heuristic evaluation seeder (Shambhu)', 5, 'done', _developerUid, 'sprint_6', now.subtract(const Duration(days: 18))),
      ('hist_t6_4', 'Build event log live stream widget (Shiva CQRS)',             4, 'done', _managerUid,   'sprint_6', now.subtract(const Duration(days: 17))),
      // ── Sprint 7 — velocity 21 pts ──────────────────────────────────────────
      // Scope: Cloud Functions + cost research. Above target — team recovered.
      ('hist_t7_1', 'Deploy Cloud Functions: onTaskStatusChange trigger',         8, 'done', _managerUid,   'sprint_7', now.subtract(const Duration(days: 12))),
      ('hist_t7_2', 'Implement sensitivity analysis engine (7 scenarios)',        5, 'done', _managerUid,   'sprint_7', now.subtract(const Duration(days: 11))),
      ('hist_t7_3', 'Implement Optimism Bias module (Kahneman & Tversky, 1979)', 5, 'done', _developerUid, 'sprint_7', now.subtract(const Duration(days: 10))),
      ('hist_t7_4', 'Build data validation outlier detection layer (Little, 2006)',3,'done', _developerUid, 'sprint_7', now.subtract(const Duration(days: 9))),
      // ── Sprint 8 — velocity 9 pts ───────────────────────────────────────────
      // Scope: TECHNICAL DEBT — unplanned refactoring blocked 11 pts. vel=9.
      ('hist_t8_1', 'Resolve critical auth middleware technical debt',            3, 'done', _managerUid,   'sprint_8', now.subtract(const Duration(days: 7))),
      ('hist_t8_2', 'Refactor Firestore query layer — remove N+1 read pattern',  3, 'done', _developerUid, 'sprint_8', now.subtract(const Duration(days: 6))),
      ('hist_t8_3', 'Fix provider memory leak and dispose stream subscriptions',  3, 'done', _developerUid, 'sprint_8', now.subtract(const Duration(days: 6))),
      // ── Sprint 9 — velocity 16 pts ──────────────────────────────────────────
      // Scope: Event sourcing + CQRS. Stabilising after debt sprint.
      ('hist_t9_1', 'Implement Event Sourcing module — immutable event log',      5, 'done', _managerUid,   'sprint_9', now.subtract(const Duration(days: 5))),
      ('hist_t9_2', 'Build CQRS command/query separation pattern',                5, 'done', _developerUid, 'sprint_9', now.subtract(const Duration(days: 4))),
      ('hist_t9_3', 'Implement infrastructure_metrics live document (Shiva)',     3, 'done', _developerUid, 'sprint_9', now.subtract(const Duration(days: 4))),
      ('hist_t9_4', 'Write Cloud Function onSprintStatusChange handler',          3, 'done', _managerUid,   'sprint_9', now.subtract(const Duration(days: 3))),
      // ── Sprint 10 — velocity 20 pts ─────────────────────────────────────────
      // Scope: Security + RBAC. Back on track — normal velocity.
      ('hist_t10_1','Implement Firestore RBAC rules (15 pen test scenarios)',     8, 'done', _managerUid,   'sprint_10', now.subtract(const Duration(days: 3))),
      ('hist_t10_2','Run ATAM architecture evaluation and document trade-offs',   5, 'done', _developerUid, 'sprint_10', now.subtract(const Duration(days: 2))),
      ('hist_t10_3','Implement CAP Theorem AP model justification document',      4, 'done', _developerUid, 'sprint_10', now.subtract(const Duration(days: 2))),
      ('hist_t10_4','Seed rbac_security_tests collection (15 individual docs)',   3, 'done', _managerUid,   'sprint_10', now.subtract(const Duration(days: 1))),
      // ── Sprint 11 — velocity 13 pts ─────────────────────────────────────────
      // Scope: Integration + HCI eval. TEAM CAPACITY — member absent 5 days.
      ('hist_t11_1','Complete TTI benchmarking evaluation (Shambhu OBJ 2)',       5, 'done', _managerUid,   'sprint_11', now.subtract(const Duration(days: 1))),
      ('hist_t11_2','Final integration testing across all 5 research screens',    5, 'done', _developerUid, 'sprint_11', now.subtract(const Duration(days: 1))),
      ('hist_t11_3','Dissertation evaluation data collection preparation',         3, 'done', _managerUid,   'sprint_11', now.subtract(const Duration(days: 1))),
    ];

    int count = 0;

    for (final (id, title, pts, status, assignee, sprint, component, completedAt) in sprint12Tasks) {
      await _db.collection('projects').doc(_projectId).collection('tasks').doc(id).set({
        'title': title, 'description': '', 'storyPoints': pts, 'status': status,
        'assigneeId': assignee, 'sprintId': sprint,
        'researchComponent': component,
        'createdAt':   Timestamp.fromDate(DateTime(2026, 3, 16)),
        'updatedAt':   Timestamp.fromDate(completedAt ?? now),
        'completedAt': completedAt != null ? Timestamp.fromDate(completedAt) : null,
      });
      count++;
    }

    for (final (id, title, pts, status, assignee, sprint, completedAt) in historicTasks) {
      await _db.collection('projects').doc(_projectId).collection('tasks').doc(id).set({
        'title': title, 'description': '', 'storyPoints': pts, 'status': status,
        'assigneeId': assignee, 'sprintId': sprint,
        'createdAt':   Timestamp.fromDate(completedAt),
        'updatedAt':   Timestamp.fromDate(completedAt),
        'completedAt': Timestamp.fromDate(completedAt),
      });
      count++;
    }

    print('  $count task documents seeded (${sprint12Tasks.length} sprint_12 + ${historicTasks.length} historic) ✓');
  }
}
