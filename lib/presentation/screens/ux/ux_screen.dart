// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/info_icon_button.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Shambhu Chapagain — Mobile UI / HCI Research Screen
// OBJ 1: Nielsen (1994) 10 Heuristics
// OBJ 2: TTI Benchmarking — Dashboard vs Spreadsheet
// OBJ 3: Cognitive Load — Miller (1956) 7±2 Limit
// OBJ 4: Dashboard vs Spreadsheet Speedup
// OBJ 5: WCAG 2.1 AA Accessibility
// ══════════════════════════════════════════════════════════════════════════════

class UXScreen extends StatefulWidget {
  const UXScreen({super.key});

  @override
  State<UXScreen> createState() => _UXScreenState();
}

class _UXScreenState extends State<UXScreen> {
  Map<String, dynamic>? _masterDoc;
  Map<String, dynamic>? _nielsenDoc;
  Map<String, dynamic>? _ttiDoc;
  Map<String, dynamic>? _cogLoadDoc;
  Map<String, dynamic>? _wcagDoc;
  // Advanced HCI docs — all 7 seeded by SeederShambhu._seedAdvancedHCI()
  Map<String, dynamic>? _aueDoc;           // aesthetic_usability_effect
  Map<String, dynamic>? _foragingDoc;      // information_foraging
  Map<String, dynamic>? _gestaltDoc;       // gestalt_principles
  Map<String, dynamic>? _uncertaintyDoc;   // uncertainty_visualisation
  Map<String, dynamic>? _sensemakingDoc;   // sensemaking_evaluation
  Map<String, dynamic>? _ucdDoc;           // ucd_process_log
  Map<String, dynamic>? _preattentiveDoc;  // preattentive_processing
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db   = FirebaseFirestore.instance;
      final base = db.collection('research_evaluation').doc('shambhu_ui');
      final adv  = base.collection('advanced_hci');
      final results = await Future.wait([
        base.get(),
        base.collection('heuristic_evaluation').doc('nielsen_10').get(),
        base.collection('time_to_insight').doc('tti_benchmark').get(),
        base.collection('cognitive_load').doc('miller_analysis').get(),
        base.collection('accessibility').doc('wcag_21_aa').get(),
        adv.doc('aesthetic_usability_effect').get(),
        adv.doc('information_foraging').get(),
        adv.doc('gestalt_principles').get(),
        adv.doc('uncertainty_visualisation').get(),
        adv.doc('sensemaking_evaluation').get(),
        adv.doc('ucd_process_log').get(),
        adv.doc('preattentive_processing').get(),
      ]);
      if (mounted) {
        setState(() {
          _masterDoc      = results[0].data();
          _nielsenDoc     = results[1].data();
          _ttiDoc         = results[2].data();
          _cogLoadDoc     = results[3].data();
          _wcagDoc        = results[4].data();
          _aueDoc         = results[5].data();
          _foragingDoc    = results[6].data();
          _gestaltDoc     = results[7].data();
          _uncertaintyDoc = results[8].data();
          _sensemakingDoc = results[9].data();
          _ucdDoc         = results[10].data();
          _preattentiveDoc= results[11].data();
          _loading        = false;
        });
      }
    } catch (e) {
      print('UXScreen load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(width: 10, height: 10,
                decoration: const BoxDecoration(color: AppColors.shambhu, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            const Text('UX Research Engine'),
          ],
        ),
        actions: [
          if (_masterDoc != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.shambhu.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nielsen: ${(_masterDoc!['nielsenOverallScore'] as num?)?.toStringAsFixed(2) ?? '—'}/10',
                style: const TextStyle(fontSize: 12, color: AppColors.shambhu, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _masterDoc == null
              ? const Center(child: Text('No UX data — restart emulators and reseed.'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shambhu banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.shambhu.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.shambhu.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.person_outlined, color: AppColors.shambhu, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Shambhu Chapagain — Mobile UI / HCI Research\nNielsen Heuristics · TTI · Cognitive Load · WCAG 2.1 AA',
                                  style: TextStyle(fontSize: 12, color: AppColors.shambhu),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Summary KPI tiles ──────────────────────────────
                        _sectionTitle('Research Summary',
                          infoTitle: 'UX Research Summary',
                          infoSummary: 'Four headline metrics from Shambhu\'s HCI evaluation — each represents a key research objective outcome.',
                          infoMetrics: const [
                            (label: 'Nielsen Score', value: 'Average of 3 evaluators across 10 heuristics — target ≥ 8.0'),
                            (label: 'TTI (Expert)', value: 'Time-to-Insight: seconds from login to identifying riskiest metric'),
                            (label: 'Speedup', value: 'Dashboard TTI ÷ Spreadsheet TTI — how many times faster than Excel'),
                            (label: 'WCAG AA', value: 'All 5 colour combinations pass WCAG 2.1 AA 4.5:1 contrast minimum'),
                          ],
                          infoReference: 'Shambhu (UX) — OBJ 1–5 Summary.\nNielsen (1994); W3C WCAG 2.1 (2018).',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _KpiTile(
                            label: 'Nielsen Score',
                            value: '${(_masterDoc!['nielsenOverallScore'] as num?)?.toStringAsFixed(2) ?? '—'}/10',
                            good: ((_masterDoc!['nielsenOverallScore'] as num?) ?? 0) >= 8.0,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _KpiTile(
                            label: 'TTI Expert',
                            value: '${(_masterDoc!['ttiExpertAvgSeconds'] as num?)?.toStringAsFixed(1) ?? '—'} s',
                            good: ((_masterDoc!['ttiExpertAvgSeconds'] as num?) ?? 99) < 30,
                          )),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _KpiTile(
                            label: 'Avg Speedup vs Excel',
                            value: '${(_masterDoc!['avgSpeedupFactor'] as num?)?.toStringAsFixed(1) ?? '—'}×',
                            good: ((_masterDoc!['avgSpeedupFactor'] as num?) ?? 0) >= 2.0,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _KpiTile(
                            label: 'WCAG 2.1 AA',
                            value: (_masterDoc!['wcagPass'] as bool? ?? false) ? 'PASS' : 'FAIL',
                            good: _masterDoc!['wcagPass'] as bool? ?? false,
                          )),
                        ]),
                        const SizedBox(height: 24),

                        // ── Nielsen 10 Heuristics ──────────────────────────
                        _sectionTitle('Nielsen Heuristic Evaluation',
                          infoTitle: 'Nielsen Heuristic Evaluation (OBJ 1)',
                          infoSummary: 'Three independent evaluators scored each of Nielsen\'s 10 usability heuristics on a 1–10 scale. Scores are averaged for consensus. Target ≥ 8.0 per heuristic.',
                          infoMetrics: const [
                            (label: 'Method', value: 'Heuristic Evaluation — systematic inspection of UI against 10 principles'),
                            (label: 'Evaluators', value: '3 evaluators — averaged for consensus score'),
                            (label: 'Scale', value: '1–10  →  ≥ 8.0 = pass, < 8.0 = improvement needed'),
                            (label: 'Colour code', value: 'Green ≥ 8.0 · Amber 7.0–7.9 · Red < 7.0'),
                          ],
                          infoReference: 'Shambhu (UX) — OBJ 1: Heuristic Evaluation.\nNielsen (1994) Heuristic Evaluation as a Usability Inspection Method.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_nielsenDoc != null) _NielsenCard(doc: _nielsenDoc!),
                        const SizedBox(height: 24),

                        // ── TTI Benchmark ──────────────────────────────────
                        _sectionTitle('Time-to-Insight Benchmark',
                          infoTitle: 'Time-to-Insight (TTI) Benchmark (OBJ 2)',
                          infoSummary: 'Measures how quickly users can identify the riskiest KPI after logging in. Benchmarked across 3 experience profiles, 10 trials each. Compared against Microsoft Excel baseline.',
                          infoMetrics: const [
                            (label: 'Task', value: 'From login: identify whether the project is on track and name the riskiest metric'),
                            (label: 'Profiles', value: 'Expert (daily Scrum user) · Intermediate (occasional reviews) · Novice (no Scrum training)'),
                            (label: 'SLA Target', value: '< 30 seconds for all profiles'),
                            (label: 'Speedup', value: 'Spreadsheet avg TTI ÷ Dashboard avg TTI — higher = faster'),
                          ],
                          infoReference: 'Shambhu (UX) — OBJ 2: TTI Benchmarking.\nNorman (1988) The Design of Everyday Things.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_ttiDoc != null) _TtiCard(doc: _ttiDoc!),
                        const SizedBox(height: 24),

                        // ── Cognitive Load ─────────────────────────────────
                        _sectionTitle('Cognitive Load Analysis',
                          infoTitle: 'Cognitive Load Analysis (OBJ 3)',
                          infoSummary: 'Counts distinct cognitive units per screen and checks against Miller\'s 7±2 limit. Expert screens intentionally exceed the limit — information density is a design requirement for those audiences.',
                          infoMetrics: const [
                            (label: 'Miller\'s Law', value: 'Humans can hold 7 ± 2 items in working memory simultaneously — Miller (1956)'),
                            (label: 'Cognitive Load Theory', value: 'Intrinsic load (task complexity) vs Extraneous load (UI noise) — Sweller (1988)'),
                            (label: 'Chunking', value: 'Expert users group related items as single concepts, reducing effective unit count'),
                            (label: 'Target', value: 'Operational screens (Dashboard, Tasks) ≤ 7 units · Expert screens may exceed'),
                          ],
                          infoReference: 'Shambhu (UX) — OBJ 3: Cognitive Load.\nMiller (1956) Magical Number 7; Sweller (1988) Cognitive Load Theory.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_cogLoadDoc != null) _CogLoadCard(doc: _cogLoadDoc!),
                        const SizedBox(height: 24),

                        // ── WCAG ──────────────────────────────────────────
                        _sectionTitle('WCAG 2.1 AA Accessibility',
                          infoTitle: 'WCAG 2.1 AA Accessibility (OBJ 5)',
                          infoSummary: 'All status badge colour combinations tested against the WCAG 2.1 AA minimum contrast ratio of 4.5:1. Status indicators also convey meaning through text and icon — not colour alone.',
                          infoMetrics: const [
                            (label: 'WCAG 2.1 AA', value: 'Minimum contrast ratio 4.5:1 for normal text'),
                            (label: 'Criterion 1.4.1', value: 'Use of Colour — information not conveyed by colour alone (text + icon also used)'),
                            (label: 'Target users', value: '~8% of males have colour vision deficiency (Birch, 2012) — design must not rely on colour alone'),
                          ],
                          infoReference: 'Shambhu (UX) — OBJ 5: Accessibility.\nW3C WCAG 2.1 (2018); Birch (2012) prevalence of colour vision deficiency.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_wcagDoc != null) _WcagCard(doc: _wcagDoc!),
                        const SizedBox(height: 24),

                        // ── Aesthetic-Usability Effect ─────────────────────
                        _sectionTitle('Aesthetic-Usability Effect',
                          infoTitle: 'Aesthetic-Usability Effect',
                          infoSummary: 'Measures correlation between aesthetic score and perceived usability per screen. Tractinsky (1997) showed that beautiful interfaces are perceived as more usable — even before any interaction.',
                          infoMetrics: const [
                            (label: 'Aesthetic Score', value: 'Evaluator rating 1–10 on visual appeal and design quality'),
                            (label: 'Perceived Usability', value: 'Evaluator rating 1–10 on how easy the screen appears to use'),
                            (label: 'Pearson r', value: 'Correlation between aesthetic and usability scores — r > 0.7 confirms the effect'),
                          ],
                          infoReference: 'Shambhu (UX) — Advanced HCI.\nTractinsky (1997) What is Beautiful is Usable.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_aueDoc != null) _AueCard(doc: _aueDoc!),
                        const SizedBox(height: 24),

                        // ── Information Foraging ───────────────────────────
                        _sectionTitle('Information Foraging Theory',
                          infoTitle: 'Information Foraging Theory',
                          infoSummary: 'Rates how well each screen guides users to critical data — called "information scent". Strong scent means users find what they need quickly; weak scent means they feel lost.',
                          infoMetrics: const [
                            (label: 'Information Scent', value: 'Scale 1–5: 1 = no guidance (user lost) · 5 = instantly guided to critical data'),
                            (label: 'Patch Quality', value: 'Whether the found information is worth the search cost'),
                            (label: 'Enriched foraging', value: 'User is directed to critical data immediately — no scanning required'),
                          ],
                          infoReference: 'Shambhu (UX) — Advanced HCI.\nPirolli & Card (1999) Information Foraging Theory.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_foragingDoc != null) _ForagingCard(doc: _foragingDoc!),
                        const SizedBox(height: 24),

                        // ── Gestalt Principles ─────────────────────────────
                        _sectionTitle('Gestalt Principles Audit',
                          infoTitle: 'Gestalt Principles Audit',
                          infoSummary: 'Audits how well each screen applies the five Gestalt visual organisation laws. These principles explain why users group and perceive visual elements as related or separate.',
                          infoMetrics: const [
                            (label: 'Proximity', value: 'Related items placed close together — e.g. KPI cards in a 2×2 grid'),
                            (label: 'Similarity', value: 'Items that look alike are perceived as the same type — status badge colours'),
                            (label: 'Enclosure', value: 'Card borders create visual containers — each metric is a distinct data object'),
                            (label: 'Figure-Ground', value: 'White cards on grey background — content stands out from page'),
                            (label: 'Continuity', value: 'Visual flow implies sequence — list scroll, chart lines'),
                          ],
                          infoReference: 'Shambhu (UX) — Advanced HCI.\nWertheimer (1923) Laws of Organisation in Perceptual Forms.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_gestaltDoc != null) _GestaltCard(doc: _gestaltDoc!),
                        const SizedBox(height: 24),

                        // ── Uncertainty Visualisation ──────────────────────
                        _sectionTitle('Uncertainty Visualisation',
                          infoTitle: 'Uncertainty Visualisation (P10/P50/P90)',
                          infoSummary: 'Evaluates how well the Monte Carlo Cone of Uncertainty is communicated on a small mobile screen. Probabilistic data is notoriously difficult to visualise without causing misinterpretation.',
                          infoMetrics: const [
                            (label: 'P10', value: 'Optimistic bound — 10% of simulations finish by this sprint'),
                            (label: 'P50', value: 'Expected outcome — 50% of simulations (median)'),
                            (label: 'P90', value: 'Pessimistic bound — 90% of simulations (high-confidence)'),
                            (label: 'Mobile constraint', value: 'Fan charts rejected — require landscape viewport, violate H8 Minimalist Design'),
                          ],
                          infoReference: 'Shambhu (UX) — Advanced HCI.\nBostrom et al. (2008) Evaluating probabilistic forecast visualisation.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_uncertaintyDoc != null) _UncertaintyCard(doc: _uncertaintyDoc!),
                        const SizedBox(height: 24),

                        // ── Sensemaking ────────────────────────────────────
                        _sectionTitle('Sensemaking Evaluation',
                          infoTitle: 'Sensemaking Evaluation',
                          infoSummary: 'Compares how quickly and accurately users can build a correct mental model of project health using AgileVision vs a static spreadsheet report. Sensemaking is the process of turning data into understanding.',
                          infoMetrics: const [
                            (label: 'Klein data-frame model', value: 'Users build mental frames from data → anomaly triggers frame update → action'),
                            (label: 'AgileVision advantage', value: 'Real-time anomaly detection enables frame update within the same sprint'),
                            (label: 'Spreadsheet limitation', value: 'End-of-sprint report means anomaly not noticed until 14 days later'),
                            (label: 'Sensemaking ratio', value: 'AgileVision sensemaking score ÷ Spreadsheet score — higher = faster understanding'),
                          ],
                          infoReference: 'Shambhu (UX) — Advanced HCI.\nKlein et al. (2006) Data-Frame Theory of Sensemaking; Few (2006) Information Dashboard Design.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_sensemakingDoc != null) _SensemakingCard(doc: _sensemakingDoc!),
                        const SizedBox(height: 24),

                        // ── UCD Process Log ────────────────────────────────
                        _sectionTitle('UCD Process Log',
                          infoTitle: 'User-Centred Design Process Log',
                          infoSummary: 'Documents 5 iterative design decisions made during development — each one following Norman\'s action cycle: identify a gulf of evaluation, propose a fix, validate with feedback.',
                          infoMetrics: const [
                            (label: 'Gulf of evaluation', value: 'When users cannot tell from the UI what state the system is in (Norman, 2013)'),
                            (label: 'DSR Exaptation', value: 'Repurposing existing design knowledge (Gestalt, Nielsen) in a new domain (mobile Agile KPI)'),
                            (label: 'UCD iteration', value: 'Design → prototype → user feedback → redesign cycle'),
                          ],
                          infoReference: 'Shambhu (UX) — Advanced HCI.\nNorman (2013) The Design of Everyday Things; Gregor & Hevner (2013) DSR Exaptation.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_ucdDoc != null) _UcdCard(doc: _ucdDoc!),
                        const SizedBox(height: 24),

                        // ── Pre-attentive Processing ───────────────────────
                        _sectionTitle('Pre-attentive Processing Audit',
                          infoTitle: 'Pre-attentive Processing Audit',
                          infoSummary: 'Pre-attentive features are visual properties (colour, size, position, shape) that the human visual system detects in under 250ms — before conscious attention. This audit verifies AgileVision\'s critical cues are pre-attentive.',
                          infoMetrics: const [
                            (label: 'Threshold', value: '< 250ms detection time = pre-attentive (Ware, 2012)'),
                            (label: 'Status badge', value: 'Red/amber/green detected in ~80ms — project health communicated before conscious processing'),
                            (label: 'Value size (24px)', value: 'Large numbers pop out from labels in ~120ms — data salient before reading'),
                            (label: 'Position (top card)', value: 'Topmost card receives first eye fixation — F-pattern reading (Nielsen, 2006)'),
                          ],
                          infoReference: 'Shambhu (UX) — Advanced HCI.\nWare (2012) Information Visualization: Perception for Design.',
                          infoResearcher: 'Shambhu — Mobile UI / HCI Engine',
                        ),
                        const SizedBox(height: 12),
                        if (_preattentiveDoc != null) _PreattentiveCard(doc: _preattentiveDoc!),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _sectionTitle(String title,
      {String? infoTitle,
      String? infoSummary,
      List<({String label, String value})> infoMetrics = const [],
      String? infoReference,
      String? infoResearcher}) {
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
    if (infoTitle != null && infoSummary != null) {
      return Row(children: [
        Text(title, style: style),
        const SizedBox(width: 4),
        InfoIconButton(
          title: infoTitle,
          summary: infoSummary,
          metrics: infoMetrics,
          reference: infoReference ?? '',
          researcher: infoResearcher ?? '',
        ),
      ]);
    }
    return Text(title, style: style);
  }
}

// ── KPI tile ──────────────────────────────────────────────────────────────────
class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final bool good;
  const _KpiTile({required this.label, required this.value, required this.good});

  @override
  Widget build(BuildContext context) {
    final color = good ? AppColors.success : AppColors.danger;
    final bg    = good ? AppColors.successLight : AppColors.dangerLight;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(good ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Nielsen Heuristics Card ───────────────────────────────────────────────────
class _NielsenCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _NielsenCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final heuristics = (doc['heuristics'] as List<dynamic>?) ?? [];
    final overall    = (doc['overallScore'] as num?)?.toStringAsFixed(2) ?? '—';
    final passing    = doc['passingHeuristics'] as int? ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.rule_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text('Overall: $overall/10 · $passing/10 heuristics pass (≥8.0)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))),
              ],
            ),
          ),
          // Heuristic rows
          ...heuristics.asMap().entries.map((e) {
            final h      = e.value as Map<String, dynamic>;
            final score  = (h['consensusScore'] as num?)?.toDouble() ?? 0;
            final passes = h['passes'] as bool? ?? false;
            final color  = score >= 8.0 ? AppColors.success : score >= 7.0 ? AppColors.warning : AppColors.danger;
            final bg     = score >= 8.0 ? AppColors.successLight : score >= 7.0 ? AppColors.warningLight : AppColors.dangerLight;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(h['id'] as String? ?? '',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        child: Text(h['name'] as String? ?? '',
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                        child: Text(score.toStringAsFixed(1),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                      ),
                      const SizedBox(width: 8),
                      Icon(passes ? Icons.check_circle_outline : Icons.cancel_outlined,
                          size: 16, color: color),
                    ],
                  ),
                ),
                if (e.key < heuristics.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── TTI Card ──────────────────────────────────────────────────────────────────
class _TtiCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _TtiCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final dash     = doc['dashboardResults'] as Map<String, dynamic>? ?? {};
    final ss       = doc['spreadsheetBaseline'] as Map<String, dynamic>? ?? {};
    final speedups = doc['speedupFactors'] as Map<String, dynamic>? ?? {};

    final profiles = [
      ('Expert',       'expert'),
      ('Intermediate', 'intermediate'),
      ('Novice',       'novice'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(children: [
              Expanded(flex: 3, child: Text('Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
              Expanded(flex: 2, child: Text('Dashboard', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Spreadsheet', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('Speedup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary), textAlign: TextAlign.center)),
            ]),
          ),
          ...profiles.asMap().entries.map((entry) {
            final (label, key) = entry.value;
            final dAvg    = (dash[key]?['avgSeconds'] as num?)?.toStringAsFixed(1) ?? '—';
            final sAvg    = (ss[key]?['avgSeconds'] as num?)?.toStringAsFixed(1) ?? '—';
            final speedup = (speedups[key] as num?)?.toStringAsFixed(2) ?? '—';
            final passes  = dash[key]?['slaPass'] as bool? ?? false;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    Expanded(flex: 3, child: Row(children: [
                      Icon(passes ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                          size: 14, color: passes ? AppColors.success : AppColors.warning),
                      const SizedBox(width: 6),
                      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    ])),
                    Expanded(flex: 2, child: Text('$dAvg s',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.shambhu),
                        textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Text('$sAvg s',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center)),
                    Expanded(flex: 2, child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
                      child: Text('${speedup}×',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success),
                          textAlign: TextAlign.center),
                    )),
                  ]),
                ),
                if (entry.key < profiles.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
          // Conclusion
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              doc['ttiConclusion'] as String? ?? '',
              style: const TextStyle(fontSize: 11.5, height: 1.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cognitive Load Card ───────────────────────────────────────────────────────
class _CogLoadCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _CogLoadCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final screens = (doc['screens'] as List<dynamic>?) ?? [];
    final within  = doc['screensWithinMillerLimit'] as int? ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
              const Icon(Icons.psychology_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('$within/5 screens within Miller\'s 7±2 limit',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ]),
          ),
          ...screens.asMap().entries.map((entry) {
            final s      = entry.value as Map<String, dynamic>;
            final units  = s['totalCognitiveUnits'] as int? ?? 0;
            final within = s['withinMillerLimit'] as bool? ?? false;
            final count  = s['metricsCount'] as int? ?? 0;
            final color  = within ? AppColors.success : AppColors.warning;
            final bg     = within ? AppColors.successLight : AppColors.warningLight;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s['screen'] as String? ?? '',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('$count primary metrics',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
                      child: Text('$units units',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                    ),
                    const SizedBox(width: 8),
                    Icon(within ? Icons.check_circle_outline : Icons.info_outline,
                        size: 16, color: color),
                  ]),
                ),
                if (entry.key < screens.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              doc['cognitiveLoadConclusion'] as String? ?? '',
              style: const TextStyle(fontSize: 11.5, height: 1.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// ── WCAG Card ─────────────────────────────────────────────────────────────────
class _WcagCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _WcagCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final tests   = (doc['colourContrastTests'] as List<dynamic>?) ?? [];
    final nonCol  = (doc['nonColourIndicators'] as List<dynamic>?) ?? [];
    final overall = doc['overallWcagPass'] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: overall ? AppColors.successLight : AppColors.dangerLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(children: [
              Icon(overall ? Icons.verified_outlined : Icons.cancel_outlined,
                  size: 16, color: overall ? AppColors.success : AppColors.danger),
              const SizedBox(width: 8),
              Text(overall ? 'WCAG 2.1 AA — ALL PASS · Minimum 4.5:1 contrast ratio met' : 'WCAG 2.1 AA — FAIL',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: overall ? AppColors.success : AppColors.danger)),
            ]),
          ),

          // Colour contrast tests
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: const Text('Colour Contrast Tests',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          ...tests.asMap().entries.map((entry) {
            final t      = entry.value as Map<String, dynamic>;
            final passes = t['passes'] as bool? ?? false;
            final ratio  = (t['contrastRatio'] as num?)?.toStringAsFixed(1) ?? '—';
            final color  = passes ? AppColors.success : AppColors.danger;
            final bg     = passes ? AppColors.successLight : AppColors.dangerLight;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(children: [
                    Expanded(child: Text(t['element'] as String? ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                      child: Text('${ratio}:1',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                    ),
                  ]),
                ),
                if (entry.key < tests.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),

          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: const Text('Non-Colour Indicators',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          ...nonCol.map((nc) {
            final n    = nc as Map<String, dynamic>;
            final pass = n['pass'] as bool? ?? false;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(pass ? Icons.check_circle_outline : Icons.cancel_outlined,
                    size: 14, color: pass ? AppColors.success : AppColors.danger),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n['finding'] as String? ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  Text(n['wcagCriterion'] as String? ?? '',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ])),
              ]),
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              doc['accessibilityConclusion'] as String? ?? '',
              style: const TextStyle(fontSize: 11.5, height: 1.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _scoreBadge(double score, {double good = 8.0, double warn = 6.0}) {
  final color = score >= good ? AppColors.success : score >= warn ? AppColors.warning : AppColors.danger;
  final bg    = score >= good ? AppColors.successLight : score >= warn ? AppColors.warningLight : AppColors.dangerLight;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Text(score.toStringAsFixed(1),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
  );
}

Widget _conclusionFooter(String text) => Container(
  padding: const EdgeInsets.all(12),
  decoration: const BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
  ),
  child: Text(text,
      style: const TextStyle(fontSize: 11.5, height: 1.55, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
);

Widget _cardShell({required String header, required List<Widget> children}) =>
    Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(header,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          ...children,
        ],
      ),
    );

// ── 1. Aesthetic-Usability Effect ─────────────────────────────────────────────
class _AueCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _AueCard({required this.doc});
  @override
  Widget build(BuildContext context) {
    final evidence   = (doc['evidence'] as List<dynamic>?) ?? [];
    final aesthetic  = (doc['aestheticScore'] as num?)?.toStringAsFixed(1) ?? '—';
    final usability  = (doc['perceivedUsabilityScore'] as num?)?.toStringAsFixed(1) ?? '—';
    final r          = (doc['correlation'] as num?)?.toStringAsFixed(2) ?? '—';
    final conclusion = doc['conclusion'] as String? ?? '';
    return _cardShell(
      header: 'Avg Aesthetic: $aesthetic/10 · Avg Perceived Usability: $usability/10 · Pearson r = $r',
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(flex: 3, child: Text('Screen', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
            Expanded(flex: 2, child: Text('Aesthetic', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('Usability', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary), textAlign: TextAlign.center)),
          ]),
        ),
        const Divider(height: 1),
        ...evidence.asMap().entries.map((e) {
          final row = e.value as Map<String, dynamic>;
          final a   = (row['aestheticScore'] as num?)?.toDouble() ?? 0;
          final u   = (row['perceivedUsabilityScore'] as num?)?.toDouble() ?? 0;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Expanded(flex: 3, child: Text(row['screen'] as String? ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                Expanded(flex: 2, child: Center(child: _scoreBadge(a))),
                Expanded(flex: 2, child: Center(child: _scoreBadge(u))),
              ]),
            ),
            if (e.key < evidence.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
          ]);
        }),
        _conclusionFooter(conclusion),
      ],
    );
  }
}

// ── 2. Information Foraging ───────────────────────────────────────────────────
class _ForagingCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _ForagingCard({required this.doc});
  @override
  Widget build(BuildContext context) {
    final screens    = (doc['screens'] as List<dynamic>?) ?? [];
    final avg        = (doc['avgScentScore'] as num?)?.toStringAsFixed(2) ?? '—';
    final conclusion = doc['conclusion'] as String? ?? '';
    return _cardShell(
      header: 'Avg Information Scent: $avg / 5.0  (1=lost · 5=instantly guided)',
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(flex: 3, child: Text('Screen', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
            Expanded(flex: 2, child: Text('Scent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('Strength', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary), textAlign: TextAlign.center)),
          ]),
        ),
        const Divider(height: 1),
        ...screens.asMap().entries.map((e) {
          final s        = e.value as Map<String, dynamic>;
          final score    = (s['informationScentScore'] as num?)?.toDouble() ?? 0;
          final strength = s['scentStrength'] as String? ?? '';
          final sc = strength == 'strong' ? AppColors.success : strength == 'moderate' ? AppColors.warning : AppColors.danger;
          final sb = strength == 'strong' ? AppColors.successLight : strength == 'moderate' ? AppColors.warningLight : AppColors.dangerLight;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Expanded(flex: 3, child: Text(s['screen'] as String? ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                Expanded(flex: 2, child: Center(child: _scoreBadge(score, good: 4.0, warn: 3.0))),
                Expanded(flex: 2, child: Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: sb, borderRadius: BorderRadius.circular(10)),
                  child: Text(strength, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sc)),
                ))),
              ]),
            ),
            if (e.key < screens.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
          ]);
        }),
        _conclusionFooter(conclusion),
      ],
    );
  }
}

// ── 3. Gestalt Principles ─────────────────────────────────────────────────────
class _GestaltCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _GestaltCard({required this.doc});
  @override
  Widget build(BuildContext context) {
    final screens    = (doc['screens'] as List<dynamic>?) ?? [];
    final overall    = (doc['overallGestaltScore'] as num?)?.toStringAsFixed(1) ?? '—';
    final conclusion = doc['conclusion'] as String? ?? '';
    return _cardShell(
      header: 'Overall Gestalt Score: $overall / 5.0',
      children: [
        ...screens.asMap().entries.map((se) {
          final s          = se.value as Map<String, dynamic>;
          final principles = (s['principles'] as List<dynamic>?) ?? [];
          final score      = (s['score'] as num?)?.toDouble() ?? 0;
          final maxScore   = s['maxScore'] as int? ?? 5;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(children: [
                Expanded(child: Text(s['screen'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                _scoreBadge(score, good: 4.0, warn: 3.0),
                Text(' / $maxScore', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
            ...principles.map((p) {
              final pr      = p as Map<String, dynamic>;
              final applied = pr['applied'] as bool? ?? false;
              return Padding(
                padding: const EdgeInsets.fromLTRB(28, 3, 16, 3),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(applied ? Icons.check_circle_outline : Icons.cancel_outlined, size: 14, color: applied ? AppColors.success : AppColors.danger),
                  const SizedBox(width: 6),
                  Expanded(child: RichText(text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    children: [
                      TextSpan(text: '${pr['principle']}  ', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      TextSpan(text: pr['evidence'] as String? ?? ''),
                    ],
                  ))),
                ]),
              );
            }),
            if (se.key < screens.length - 1) const Divider(height: 16, indent: 16, endIndent: 16),
          ]);
        }),
        _conclusionFooter(conclusion),
      ],
    );
  }
}

// ── 4. Uncertainty Visualisation ─────────────────────────────────────────────
class _UncertaintyCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _UncertaintyCard({required this.doc});
  @override
  Widget build(BuildContext context) {
    final results    = (doc['evaluationResults'] as List<dynamic>?) ?? [];
    final overall    = (doc['overallScore'] as num?)?.toStringAsFixed(2) ?? '—';
    final conclusion = doc['conclusion'] as String? ?? '';
    return _cardShell(
      header: 'Overall Score: $overall / 10.0  (P10/P50/P90 numeric on mobile)',
      children: [
        ...results.asMap().entries.map((e) {
          final r     = e.value as Map<String, dynamic>;
          final score = (r['score'] as num?)?.toDouble() ?? 0;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['criterion'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(r['finding'] as String? ?? '', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4)),
                ])),
                const SizedBox(width: 8),
                _scoreBadge(score, good: 7.5, warn: 5.0),
              ]),
            ),
            if (e.key < results.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
          ]);
        }),
        _conclusionFooter(conclusion),
      ],
    );
  }
}

// ── 5. Sensemaking Evaluation ─────────────────────────────────────────────────
class _SensemakingCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _SensemakingCard({required this.doc});
  @override
  Widget build(BuildContext context) {
    final scenarios  = (doc['scenarios'] as List<dynamic>?) ?? [];
    final avAV       = (doc['avgAgileVisionScore'] as num?)?.toStringAsFixed(2) ?? '—';
    final avSS       = (doc['avgSpreadsheetScore'] as num?)?.toStringAsFixed(2) ?? '—';
    final ratio      = (doc['sensemakingImprovement'] as num?)?.toStringAsFixed(2) ?? '—';
    final conclusion = doc['conclusion'] as String? ?? '';
    return _cardShell(
      header: 'AgileVision avg: $avAV · Spreadsheet avg: $avSS · Improvement: ${ratio}×',
      children: [
        ...scenarios.asMap().entries.map((e) {
          final s     = e.value as Map<String, dynamic>;
          final tool  = s['tool'] as String? ?? '';
          final score = (s['sensemakingScore'] as num?)?.toDouble() ?? 0;
          final isAV  = tool.toLowerCase().contains('agilevision') || tool.toLowerCase().contains('real-time');
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAV ? AppColors.shambhu.withValues(alpha: 0.1) : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(isAV ? 'AgileVision' : 'Spreadsheet',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isAV ? AppColors.shambhu : AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 4),
                  Text(s['scenario'] as String? ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(s['description'] as String? ?? '', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4)),
                ])),
                const SizedBox(width: 8),
                _scoreBadge(score, good: 7.0, warn: 5.0),
              ]),
            ),
            if (e.key < scenarios.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
          ]);
        }),
        _conclusionFooter(conclusion),
      ],
    );
  }
}

// ── 6. UCD Process Log ────────────────────────────────────────────────────────
class _UcdCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _UcdCard({required this.doc});
  @override
  Widget build(BuildContext context) {
    final iterations = (doc['iterations'] as List<dynamic>?) ?? [];
    final cycles     = doc['ecdCyclesCompleted'] as int? ?? 0;
    final conclusion = doc['conclusion'] as String? ?? '';
    return _cardShell(
      header: '$cycles UCD Iterations — Norman (2013) action cycle evidence',
      children: [
        ...iterations.asMap().entries.map((e) {
          final it = e.value as Map<String, dynamic>;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: Center(child: Text('${it['iteration']}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(it['stage'] as String? ?? '',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                ]),
                const SizedBox(height: 6),
                RichText(text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                  children: [
                    const TextSpan(text: 'Decision  ', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    TextSpan(text: it['decision'] as String? ?? ''),
                  ],
                )),
                const SizedBox(height: 4),
                Text(it['ecdRationale'] as String? ?? '',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.check_circle_outline, size: 13, color: AppColors.success),
                  const SizedBox(width: 4),
                  Expanded(child: Text(it['outcome'] as String? ?? '',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.success))),
                ]),
              ]),
            ),
            if (e.key < iterations.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
          ]);
        }),
        _conclusionFooter(conclusion),
      ],
    );
  }
}

// ── 7. Pre-attentive Processing ───────────────────────────────────────────────
class _PreattentiveCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _PreattentiveCard({required this.doc});
  @override
  Widget build(BuildContext context) {
    final screenAudit = (doc['screenAudit'] as List<dynamic>?) ?? [];
    final threshold   = doc['preattentiveThresholdMs'] as int? ?? 250;
    final conclusion  = doc['conclusion'] as String? ?? '';
    return _cardShell(
      header: 'Pre-attentive threshold: < ${threshold}ms — all critical cues within limit',
      children: [
        ...screenAudit.asMap().entries.map((se) {
          final s    = se.value as Map<String, dynamic>;
          final cues = (s['cues'] as List<dynamic>?) ?? [];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(s['screen'] as String? ?? '',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ),
            ...cues.map((c) {
              final cu     = c as Map<String, dynamic>;
              final ms     = cu['detectionTimeMs'] as int? ?? 0;
              final within = cu['withinThreshold'] as bool? ?? false;
              final feat   = cu['feature'] as String? ?? '';
              final fc = feat == 'colour' ? AppColors.roshan
                  : feat == 'size'     ? AppColors.devendra
                  : feat == 'position' ? AppColors.shambhu
                  : AppColors.shiva;
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 16, 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: fc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(feat, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fc)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(cu['element'] as String? ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: within ? AppColors.successLight : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('${ms}ms',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: within ? AppColors.success : AppColors.danger)),
                  ),
                ]),
              );
            }),
            if (se.key < screenAudit.length - 1) const Divider(height: 12, indent: 16, endIndent: 16),
          ]);
        }),
        _conclusionFooter(conclusion),
      ],
    );
  }
}
