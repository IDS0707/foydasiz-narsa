import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/onb_chrome.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String? _selected;

  static const List<_LangOption> _options = <_LangOption>[
    _LangOption(
      code: 'en',
      flag: '🇺🇸',
      titleKey: 'language_english',
      subtitleNative: 'English',
      gradient: AppColors.indigoGradient,
    ),
    _LangOption(
      code: 'uz',
      flag: '🇺🇿',
      titleKey: 'language_uzbek',
      subtitleNative: "O'zbekcha",
      gradient: AppColors.primaryGradient,
    ),
    _LangOption(
      code: 'ru',
      flag: '🇷🇺',
      titleKey: 'language_russian',
      subtitleNative: 'Русский',
      gradient: AppColors.pinkGradient,
    ),
  ];

  Future<void> _onPick(String code) async {
    setState(() => _selected = code);
    // Apply instantly so the rest of the screen updates copy.
    await ref
        .read(localeProvider.notifier)
        .set(Locale(code), markChosen: false);
  }

  Future<void> _onContinue() async {
    final String code = _selected ?? 'en';
    await ref.read(localeProvider.notifier).set(Locale(code));
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const OnbBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color:
                              AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.language_rounded,
                        color: Colors.white, size: 36),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        duration: 480.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(),
                  const SizedBox(height: 24),
                  Text(
                    _headlineForCurrent(context),
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                          letterSpacing: -1,
                          height: 1.1,
                        ),
                  )
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 360.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 8),
                  Text(
                    _subForCurrent(context),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color:
                              Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 360.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int i) {
                        final _LangOption o = _options[i];
                        final bool active = _selected == o.code;
                        return _LangCard(
                          option: o,
                          active: active,
                          onTap: () => _onPick(o.code),
                          translatedLabel: context.tr(o.titleKey),
                        )
                            .animate(delay: (260 + i * 90).ms)
                            .fadeIn(duration: 320.ms)
                            .slideY(begin: 0.1, curve: Curves.easeOutCubic);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _selected == null ? 0.45 : 1,
                    child: GestureDetector(
                      onTap: _selected == null ? null : _onContinue,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.45),
                              blurRadius: 22,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            context.tr('onb_continue'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15.5,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Uses the chosen language's translation when picked; otherwise falls back to
  // a multilingual headline so the screen reads natively even before any
  // selection has been made.
  String _headlineForCurrent(BuildContext context) {
    if (_selected == null) {
      return 'Choose language\nTilni tanlang\nВыберите язык';
    }
    return context.tr('onb_choose_language');
  }

  String _subForCurrent(BuildContext context) {
    if (_selected == null) {
      return 'Pick the language LIFEHUB will use everywhere.';
    }
    return context.tr('onb_choose_language_sub');
  }
}

class _LangOption {
  const _LangOption({
    required this.code,
    required this.flag,
    required this.titleKey,
    required this.subtitleNative,
    required this.gradient,
  });
  final String code;
  final String flag;
  final String titleKey;
  final String subtitleNative;
  final Gradient gradient;
}

class _LangCard extends StatelessWidget {
  const _LangCard({
    required this.option,
    required this.active,
    required this.onTap,
    required this.translatedLabel,
  });
  final _LangOption option;
  final bool active;
  final VoidCallback onTap;
  final String translatedLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: active ? option.gradient : null,
          color: active ? null : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: active
                ? Colors.transparent
                : Theme.of(context).dividerColor.withValues(alpha: 0.6),
            width: 1.4,
          ),
          boxShadow: active
              ? <BoxShadow>[
                  BoxShadow(
                    color: (option.gradient as LinearGradient)
                        .colors
                        .last
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ]
              : <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.22)
                    : Theme.of(context).dividerColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                option.flag,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    option.subtitleNative,
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    translatedLabel,
                    style: TextStyle(
                      color: active
                          ? Colors.white.withValues(alpha: 0.88)
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Theme.of(context).dividerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: active
                  ? Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: (option.gradient as LinearGradient).colors.last,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
