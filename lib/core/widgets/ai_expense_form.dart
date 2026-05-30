import 'dart:math';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/core/theme/app_colors.dart';
import 'package:expenses_tracker/core/theme/app_gradients.dart';
import 'package:expenses_tracker/core/theme/app_radii.dart';
import 'package:expenses_tracker/core/theme/app_spacing.dart';
import 'package:expenses_tracker/core/theme/app_text_styles.dart';
import 'package:expenses_tracker/core/widgets/glass_card.dart';
import 'package:expenses_tracker/core/widgets/gradient_button.dart';
import 'package:expenses_tracker/shared/animations/floating_particles.dart';
import 'package:expenses_tracker/shared/animations/pulse_animation.dart';
import 'package:expenses_tracker/shared/animations/shimmer_gradient.dart';
import 'package:expenses_tracker/core/ai/models/ai_parsed_expense.dart';

// ---------------------------------------------------------------------------
// Localisation keys used by the widget.  When the project adds a real l10n
// layer (arb + AppLocalizations) these can be swapped out without touching
// the widget layout.
// ---------------------------------------------------------------------------
class _AiFormStrings {
  final String title;
  final String hint;
  final String voiceLabel;
  final String cameraLabel;
  final String parseLabel;
  final String saveLabel;
  final String amountLabel;
  final String currencyLabel;
  final String categoryLabel;
  final String dateLabel;
  final String noteLabel;
  final String confidenceLabel;
  final String missingFieldsLabel;
  final String editHint;
  final String aiSuggestionTitle;

  const _AiFormStrings._({
    required this.title,
    required this.hint,
    required this.voiceLabel,
    required this.cameraLabel,
    required this.parseLabel,
    required this.saveLabel,
    required this.amountLabel,
    required this.currencyLabel,
    required this.categoryLabel,
    required this.dateLabel,
    required this.noteLabel,
    required this.confidenceLabel,
    required this.missingFieldsLabel,
    required this.editHint,
    required this.aiSuggestionTitle,
  });

  static const en = _AiFormStrings._(
    title: 'AI Expense',
    hint: 'Describe your expense…\ne.g. "Spent 25 EGP on lunch at Downtown"',
    voiceLabel: 'Voice',
    cameraLabel: 'Camera',
    parseLabel: 'Parse',
    saveLabel: 'Save Expense',
    amountLabel: 'Amount',
    currencyLabel: 'Currency',
    categoryLabel: 'Category',
    dateLabel: 'Date',
    noteLabel: 'Note',
    confidenceLabel: 'Confidence',
    missingFieldsLabel: 'Missing',
    editHint: 'Tap to edit',
    aiSuggestionTitle: 'AI Suggestion',
  );

  static const ar = _AiFormStrings._(
    title: 'مصروف ذكي',
    hint: 'صف مصروفك…\nمثال: "صرفت ٢٥ جنيه على الغداء في وسط البلد"',
    voiceLabel: 'صوت',
    cameraLabel: 'كاميرا',
    parseLabel: 'تحليل',
    saveLabel: 'حفظ المصروف',
    amountLabel: 'المبلغ',
    currencyLabel: 'العملة',
    categoryLabel: 'التصنيف',
    dateLabel: 'التاريخ',
    noteLabel: 'ملاحظة',
    confidenceLabel: 'الثقة',
    missingFieldsLabel: 'ناقص',
    editHint: 'اضغط للتعديل',
    aiSuggestionTitle: 'اقتراح الذكاء الاصطناعي',
  );
}

/// {@template ai_expense_form}
/// A futuristic, fully-animated AI expense form widget.
///
/// Features:
/// - Shimmer gradient background (deep purple → teal → cyan)
/// - Floating particle overlay
/// - Wave-animated text input
/// - Pulse-animated action buttons (voice / camera / parse)
/// - Slide + fade transitions for parsed result fields
/// - Confidence indicators with color-coded chips
/// - Editable auto-filled fields + empty hints for missing fields
/// - RTL (Arabic) and LTR (English) support
/// - Material 3 design tokens
///
/// The widget is self-contained and can be dropped into any screen.
/// {@endtemplate}
class AiExpenseForm extends StatefulWidget {
  /// {@macro ai_expense_form}
  const AiExpenseForm({
    super.key,
    this.locale = 'en',
    this.onParse,
    this.onVoiceTap,
    this.onCameraTap,
    this.onSave,
    this.initialInput,
    this.shimmerColors,
    this.particleColors,
  });

  /// Locale code: 'en' or 'ar'.  Anything else defaults to English.
  final String locale;

  /// Called when the user taps the Parse button.  If null the widget runs
  /// a built-in heuristic parser (offline-friendly).
  final Future<AiParsedExpense> Function(String input)? onParse;

  /// Called when the voice button is tapped.
  final VoidCallback? onVoiceTap;

  /// Called when the camera button is tapped.
  final VoidCallback? onCameraTap;

  /// Called when the user taps Save.  Receives the current [AiParsedExpense]
  /// (including any user edits).
  final void Function(AiParsedExpense parsed)? onSave;

  /// Optional initial text for the input field.
  final String? initialInput;

  /// Override shimmer gradient colors.
  final List<Color>? shimmerColors;

  /// Override floating particle colors.
  final List<Color>? particleColors;

  @override
  State<AiExpenseForm> createState() => _AiExpenseFormState();
}

class _AiExpenseFormState extends State<AiExpenseForm>
    with TickerProviderStateMixin {
  late final TextEditingController _inputController;
  late final AnimationController _waveController;
  late final AnimationController _fieldsController;
  late final List<AnimationController> _fieldControllers;
  late final List<Animation<Offset>> _fieldSlides;
  late final List<Animation<double>> _fieldFades;

  bool _isParsing = false;
  AiParsedExpense? _parsed;
  final Map<String, TextEditingController> _editControllers = {};

  _AiFormStrings get _s =>
      widget.locale.toLowerCase().startsWith('ar') ? _AiFormStrings.ar : _AiFormStrings.en;

  bool get _isRtl => widget.locale.toLowerCase().startsWith('ar');

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.initialInput);

    // Wave animation for the input field border glow.
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Master controller for staggered field entrance.
    _fieldsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fieldControllers = List.generate(5, (_) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _fieldSlides = _fieldControllers.map((c) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    }).toList();

    _fieldFades = _fieldControllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _waveController.dispose();
    _fieldsController.dispose();
    for (final c in _fieldControllers) {
      c.dispose();
    }
    for (final ec in _editControllers.values) {
      ec.dispose();
    }
    super.dispose();
  }

  Future<void> _handleParse() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isParsing = true);

    AiParsedExpense result;
    if (widget.onParse != null) {
      result = await widget.onParse!(text);
    } else {
      // Built-in offline heuristic parser.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      result = _heuristicParse(text);
    }

    if (!mounted) return;

    setState(() {
      _isParsing = false;
      _parsed = result;
      _editControllers.clear();
      _editControllers['amount'] = TextEditingController(
        text: result.amount?.toStringAsFixed(2) ?? '',
      );
      _editControllers['currency'] = TextEditingController(
        text: result.currency ?? '',
      );
      _editControllers['category'] = TextEditingController(
        text: result.category ?? '',
      );
      _editControllers['date'] = TextEditingController(
        text: result.date?.toIso8601String().split('T').first ?? '',
      );
      _editControllers['note'] = TextEditingController(
        text: result.note ?? '',
      );
    });

    // Staggered entrance for result fields.
    for (var i = 0; i < _fieldControllers.length; i++) {
      _fieldControllers[i].reset();
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) _fieldControllers[i].forward();
      });
    }
  }

  AiParsedExpense _heuristicParse(String input) {
    final lower = input.toLowerCase();
    double? amount;
    String? currency;
    String? category;
    DateTime? date;
    String? note;
    final missing = <String>['amount', 'currency', 'category', 'date', 'note'];

    // Amount
    final m = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(input);
    if (m != null) {
      amount = double.tryParse(m.group(1)!);
      if (amount != null) missing.remove('amount');
    }

    // Currency
    if (lower.contains('egp') ||
        lower.contains('pound') ||
        lower.contains('جنيه')) {
      currency = 'EGP';
      missing.remove('currency');
    } else if (lower.contains('usd') ||
        lower.contains('dollar') ||
        lower.contains('دولار')) {
      currency = 'USD';
      missing.remove('currency');
    }

    // Category
    final keywords = <String, String>{
      'food': r'food|lunch|dinner|breakfast|restaurant|meal|أكل|غدا|فطار|طعام',
      'transport': r'transport|taxi|bus|metro|uber|train|مواصلات|تاكسي|أوبر',
      'shopping': r'shopping|clothes|shoes|market|mall|تسوق|ملابس',
      'bills': r'bill|electric|water|gas|internet|phone|فاتورة|كهرباء|ماية',
      'entertainment': r'movie|cinema|game|concert|fun|سينما|لعب',
      'health': r'doctor|hospital|medicine|pharmacy|health|دكتور|صيدلية',
    };
    for (final e in keywords.entries) {
      if (RegExp(e.value, caseSensitive: false).hasMatch(lower)) {
        category = e.key;
        missing.remove('category');
        break;
      }
    }

    // Date
    final dm = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})').firstMatch(input);
    if (dm != null) {
      final d = int.tryParse(dm.group(1)!);
      final mo = int.tryParse(dm.group(2)!);
      final yStr = dm.group(3)!;
      final y = yStr.length == 2 ? 2000 + int.parse(yStr) : int.tryParse(yStr);
      if (d != null && mo != null && y != null) {
        date = DateTime(y, mo, d);
        missing.remove('date');
      }
    }
    if (date == null) {
      date = DateTime.now();
      missing.remove('date');
    }

    // Note
    note = input.trim();
    missing.remove('note');

    final found = 5 - missing.length;
    final confidence = (found / 5).clamp(0.0, 1.0);

    return AiParsedExpense(
      amount: amount,
      currency: currency,
      category: category,
      date: date,
      note: note,
      confidence: confidence,
      missingFields: List.unmodifiable(missing),
      originalInput: input,
    );
  }

  void _handleSave() {
    if (_parsed == null) return;
    final updated = _parsed!.copyWith(
      amount: double.tryParse(_editControllers['amount']?.text ?? ''),
      currency: _editControllers['currency']?.text,
      category: _editControllers['category']?.text,
      date: DateTime.tryParse(_editControllers['date']?.text ?? ''),
      note: _editControllers['note']?.text,
    );
    widget.onSave?.call(updated);
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
        children: [
          // Background layers
          ShimmerGradient(
            colors: widget.shimmerColors,
            child: const SizedBox.expand(),
          ),
          const Positioned.fill(child: FloatingParticles()),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.containerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInputCard(),
                  const SizedBox(height: AppSpacing.lg),
                  if (_parsed != null) ...[
                    _buildConfidenceChip(),
                    const SizedBox(height: AppSpacing.md),
                    _buildParsedFields(),
                    const SizedBox(height: AppSpacing.lg),
                    GradientButton(
                      label: _s.saveLabel,
                      onPressed: _handleSave,
                      gradient: AppGradients.aiAction,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            size: 20,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          _s.title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildInputCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TextField with wave-animated border glow
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              final wave = sin(_waveController.value * 2 * pi) * 0.5 + 0.5;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadii.card,
                  border: Border.all(
                    color: Color.lerp(
                      AppColors.primaryContainer.withAlpha(60),
                      AppColors.primaryContainer.withAlpha(180),
                      wave,
                    )!,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _inputController,
                  maxLines: 4,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: _s.hint,
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.outline,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // Action buttons row
          Row(
            children: [
              // Voice button
              PulseAnimation(
                delay: const Duration(milliseconds: 200),
                child: _ActionButton(
                  icon: Icons.mic_none,
                  label: _s.voiceLabel,
                  onTap: widget.onVoiceTap,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Camera button
              PulseAnimation(
                delay: const Duration(milliseconds: 400),
                child: _ActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: _s.cameraLabel,
                  onTap: widget.onCameraTap,
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              // Parse button
              PulseAnimation(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _isParsing ? null : _handleParse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      foregroundColor: AppColors.onPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                    ),
                    icon: _isParsing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 16),
                    label: Text(
                      _s.parseLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceChip() {
    final confidence = _parsed!.confidence;
    final color = confidence >= 0.8
        ? AppColors.primary
        : confidence >= 0.5
            ? Colors.orange
            : AppColors.error;

    return Align(
      alignment: _isRtl ? Alignment.centerRight : Alignment.centerLeft,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              '${_s.confidenceLabel}: ${(confidence * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.labelCaps.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsedFields() {
    final fields = [
      _FieldDef(_s.amountLabel, 'amount', _parsed!.amount?.toStringAsFixed(2)),
      _FieldDef(_s.currencyLabel, 'currency', _parsed!.currency),
      _FieldDef(_s.categoryLabel, 'category', _parsed!.category),
      _FieldDef(_s.dateLabel, 'date',
          _parsed!.date?.toIso8601String().split('T').first),
      _FieldDef(_s.noteLabel, 'note', _parsed!.note),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _s.aiSuggestionTitle,
                style: AppTextStyles.labelCaps.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(fields.length, (index) {
            final field = fields[index];
            final isMissing = _parsed!.missingFields.contains(field.key);
            final controller = _editControllers[field.key];

            return AnimatedBuilder(
              animation: _fieldControllers[index],
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fieldFades[index],
                  child: SlideTransition(
                    position: _fieldSlides[index],
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ParsedFieldRow(
                  label: field.label,
                  controller: controller!,
                  isMissing: isMissing,
                  editHint: _s.editHint,
                ),
              ),
            );
          }),
          if (_parsed!.missingFields.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _parsed!.missingFields.map((f) {
                return Chip(
                  label: Text(
                    '${_s.missingFieldsLabel}: $f',
                    style: AppTextStyles.labelCaps,
                  ),
                  backgroundColor: AppColors.errorContainer,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets & data classes
// ---------------------------------------------------------------------------

class _FieldDef {
  final String label;
  final String key;
  final String? initial;

  const _FieldDef(this.label, this.key, this.initial);
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: AppRadii.pill,
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParsedFieldRow extends StatelessWidget {
  const _ParsedFieldRow({
    required this.label,
    required this.controller,
    required this.isMissing,
    required this.editHint,
  });

  final String label;
  final TextEditingController controller;
  final bool isMissing;
  final String editHint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelCaps.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isMissing ? AppColors.outline : AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: isMissing ? editHint : null,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.outline,
            ),
            filled: true,
            fillColor: isMissing
                ? AppColors.errorContainer.withAlpha(40)
                : AppColors.inputFill,
            border: const OutlineInputBorder(
              borderRadius: AppRadii.pill,
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadii.pill,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.pill,
              borderSide: BorderSide(
                color: isMissing ? AppColors.error : AppColors.primary,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
