import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A single bullet point row inside the info dialog.
class _InfoBullet extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoBullet({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.circle, size: 5, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: value != null
                ? RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: '$label  ',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        TextSpan(text: value),
                      ],
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Model for one section inside the info dialog.
class InfoSection {
  final String? heading;
  final List<_InfoBullet> bullets;
  const InfoSection({this.heading, required this.bullets});
}

/// Small ⓘ icon that opens a structured research info dialog.
class InfoIconButton extends StatelessWidget {
  final String title;
  final String summary;
  final List<({String label, String value})> metrics;
  final String reference;
  final String researcher;

  const InfoIconButton({
    super.key,
    required this.title,
    required this.summary,
    required this.metrics,
    required this.reference,
    required this.researcher,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _InfoDialog(
          title: title,
          summary: summary,
          metrics: metrics,
          reference: reference,
          researcher: researcher,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}

class _InfoDialog extends StatelessWidget {
  final String title;
  final String summary;
  final List<({String label, String value})> metrics;
  final String reference;
  final String researcher;

  const _InfoDialog({
    required this.title,
    required this.summary,
    required this.metrics,
    required this.reference,
    required this.researcher,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Researcher badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(researcher,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                    const SizedBox(height: 12),

                    // Summary
                    Text(summary,
                        style: const TextStyle(
                            fontSize: 13, height: 1.55, color: AppColors.textSecondary)),

                    if (metrics.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      const Text('Key Formulas & Metrics',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      ...metrics.map((m) => _InfoBullet(label: m.label, value: m.value)),
                    ],

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Reference
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.menu_book_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(reference,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience row: section heading text + ⓘ icon.
class SectionHeading extends StatelessWidget {
  final String title;
  final String infoTitle;
  final String infoSummary;
  final List<({String label, String value})> infoMetrics;
  final String infoReference;
  final String infoResearcher;
  final TextStyle? style;

  const SectionHeading({
    super.key,
    required this.title,
    required this.infoTitle,
    required this.infoSummary,
    this.infoMetrics = const [],
    required this.infoReference,
    required this.infoResearcher,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: style ??
                const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        InfoIconButton(
          title: infoTitle,
          summary: infoSummary,
          metrics: infoMetrics,
          reference: infoReference,
          researcher: infoResearcher,
        ),
      ],
    );
  }
}
