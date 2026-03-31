import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../constants/app_colors.dart';
import '../../../widget/base_design/base_design.dart';
import '../model/language_option.dart';
import '../view_model/live_interpreter_view_model.dart';

class LiveInterpreterView extends StatefulWidget {
  const LiveInterpreterView({super.key});

  @override
  State<LiveInterpreterView> createState() => _LiveInterpreterViewState();
}

class _LiveInterpreterViewState extends State<LiveInterpreterView> {
  final LiveInterpreterViewModel model = LiveInterpreterViewModel();

  @override
  void initState() {
    super.initState();
    unawaited(model.init());
  }

  @override
  void dispose() {
    unawaited(model.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDesign(
      leftTitle: 'Synthex Live Interpreter',
      leading: Icon(
        Icons.translate_rounded,
        color: AppColors.primary,
        size: 30,
      ),
      viewBackBtn: false,
      bodyPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      bottomOverlayHeight: 236,
      bottomWidget: _buildInteractionDock(context),
      children: <Widget>[
        Observer(
          builder: (BuildContext context) => _buildLanguageCard(context),
        ),
        Observer(
          builder: (BuildContext context) => _buildTranscriptCard(context),
        ),
        Observer(
          builder: (BuildContext context) => _buildTranslationCard(context),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    return _buildSurfaceCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: _buildLanguagePicker(
                  context: context,
                  title: 'From',
                  value: model.sourceLanguage,
                  alignEnd: false,
                  onSelected: (LanguageOption value) async {
                    await model.changeSourceLanguage(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _buildSwapButton(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLanguagePicker(
                  context: context,
                  title: 'To',
                  value: model.targetLanguage,
                  alignEnd: true,
                  onSelected: (LanguageOption value) async {
                    await model.changeTargetLanguage(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePicker({
    required BuildContext context,
    required String title,
    required LanguageOption value,
    required bool alignEnd,
    required Future<void> Function(LanguageOption value) onSelected,
  }) {
    final TextStyle labelStyle = _labelStyle(context).copyWith(
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
      fontSize: 11,
      letterSpacing: 1.6,
      fontWeight: FontWeight.w700,
    );
    final TextStyle valueStyle = _headlineStyle(
      context,
    ).copyWith(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2);

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(title.toUpperCase(), style: labelStyle),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              unawaited(
                _showLanguagePickerSheet(
                  context: context,
                  title: title,
                  currentValue: value,
                  onSelected: onSelected,
                ),
              );
            },
            child: Ink(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: alignEnd
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      value.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
                      style: valueStyle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, AppColors.primaryContainer],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryGlow.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: IconButton(
        onPressed: model.swapLanguages,
        iconSize: 24,
        padding: const EdgeInsets.all(14),
        icon: Icon(Icons.swap_horiz_rounded, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildTranscriptCard(BuildContext context) {
    final String placeholder = model.handsFreeMode
        ? 'Tap once, speak, then pause for 2 seconds.'
        : 'Press and hold the mic button, then speak.';

    return _buildSurfaceCard(
      minHeight: 220,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCardHeader(
            context,
            icon: Icons.mic_rounded,
            title: 'Live transcript - ${model.sourceLanguage.label}',
            accentColor: AppColors.primary,
            trailing: model.hasTranscript
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildHeaderIconButton(
                        icon: Icons.volume_up_rounded,
                        accent: AppColors.primary,
                        onPressed: () {
                          unawaited(model.speakOriginalText());
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildHeaderIconButton(
                        icon: Icons.delete_outline_rounded,
                        accent: AppColors.onSurfaceVariant,
                        onPressed: model.clearTranscript,
                      ),
                    ],
                  )
                : _buildLiveDot(
                    isActive: model.isSessionActive || model.isListening,
                  ),
          ),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: Center(
              child: model.transcript.trim().isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        placeholder,
                        textAlign: TextAlign.center,
                        style: _bodyStyle(context).copyWith(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.36,
                          ),
                          fontSize: 22,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        model.transcript,
                        style: _bodyStyle(context).copyWith(
                          color: AppColors.onSurface,
                          fontSize: 19,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationCard(BuildContext context) {
    final bool hasTranslation = model.translatedText.trim().isNotEmpty;

    return _buildSurfaceCard(
      minHeight: 220,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCardHeader(
            context,
            icon: Icons.volume_up_rounded,
            title: 'Translation - ${model.targetLanguage.label}',
            accentColor: AppColors.primaryContainer,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildAutoTtsChip(context),
                if (hasTranslation) ...<Widget>[
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    icon: Icons.play_arrow_rounded,
                    accent: AppColors.primaryContainer,
                    onPressed: () {
                      unawaited(model.speakTranslatedText());
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: Center(
              child: hasTranslation
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        model.translatedText,
                        style: _bodyStyle(context).copyWith(
                          color: AppColors.onSurface,
                          fontSize: 19,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Translated text appears here.',
                        textAlign: TextAlign.center,
                        style: _bodyStyle(context).copyWith(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.28,
                          ),
                          fontSize: 22,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color accentColor,
    required Widget trailing,
    bool titleCanWrap = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: accentColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              maxLines: titleCanWrap ? 2 : 1,
              overflow: titleCanWrap
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: _headlineStyle(context).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.3,
                shadows: const <Shadow>[
                  Shadow(
                    color: Color(0x6A000000),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(padding: const EdgeInsets.only(top: 1), child: trailing),
      ],
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required Color accent,
    required VoidCallback onPressed,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.94),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        icon: Icon(icon, color: accent),
      ),
    );
  }

  Widget _buildLiveDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: (isActive ? AppColors.primary : AppColors.onSurfaceVariant)
            .withValues(alpha: isActive ? 0.95 : 0.55),
        shape: BoxShape.circle,
        boxShadow: isActive
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildAutoTtsChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        model.autoSpeakTranslation ? 'AUTO TTS' : 'MANUAL TTS',
        style: _labelStyle(context).copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.76),
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _buildInteractionDock(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Observer(
          builder: (BuildContext context) {
            if (model.errorText.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildErrorCard(context),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
        Observer(
          builder: (BuildContext context) => _buildModeSelector(context),
        ),
        const SizedBox(height: 12),
        Observer(
          builder: (BuildContext context) {
            return Text(
              model.statusText,
              textAlign: TextAlign.center,
              style: _bodyStyle(context).copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.62),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Observer(
          builder: (BuildContext context) {
            return model.handsFreeMode
                ? _buildHandsFreeButton(context)
                : _buildHoldButton(context);
          },
        ),
        Observer(
          builder: (BuildContext context) {
            if (model.micPermissionGranted) {
              return const SizedBox.shrink();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _buildSecondaryDockButton(
                      context,
                      icon: Icons.mic_rounded,
                      label: 'Grant mic',
                      onPressed: () {
                        unawaited(model.requestMicrophonePermission());
                      },
                    ),
                    _buildSecondaryDockButton(
                      context,
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onPressed: () {
                        unawaited(model.openPermissionSettings());
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.24)),
      ),
      child: Text(
        model.errorText,
        style: _bodyStyle(context).copyWith(
          color: AppColors.error,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 540),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildModeButton(
              context,
              label: 'Hold',
              selected: !model.handsFreeMode,
              onPressed: () {
                unawaited(model.setHandsFreeMode(false));
              },
            ),
          ),
          Expanded(
            child: _buildModeButton(
              context,
              label: 'Hands-free',
              selected: model.handsFreeMode,
              onPressed: () {
                unawaited(model.setHandsFreeMode(true));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, AppColors.primaryContainer],
              )
            : null,
        color: selected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: selected
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: _headlineStyle(context).copyWith(
                color: selected
                    ? AppColors.onPrimary
                    : AppColors.onSurface.withValues(alpha: 0.42),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoldButton(BuildContext context) {
    final bool isPressed = model.isSessionActive;
    final bool isDisabled = !model.nativeFeaturesSupported;

    return Listener(
      onPointerDown: isDisabled
          ? null
          : (_) {
              if (!model.isSessionActive && !model.isSessionBusy) {
                unawaited(model.startListening());
              }
            },
      onPointerUp: isDisabled
          ? null
          : (_) {
              if (model.isSessionActive ||
                  model.isSessionBusy ||
                  model.isListening) {
                unawaited(model.finishHoldTurn());
              }
            },
      onPointerCancel: isDisabled
          ? null
          : (_) {
              if (model.isSessionActive ||
                  model.isSessionBusy ||
                  model.isListening) {
                unawaited(model.finishHoldTurn());
              }
            },
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: isDisabled ? 0.5 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                isPressed ? AppColors.primaryContainer : AppColors.primary,
                AppColors.primaryContainer,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isPressed ? 0.38 : 0.28,
                ),
                blurRadius: isPressed ? 36 : 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.mic_rounded, color: AppColors.onPrimary, size: 28),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  isPressed
                      ? 'RELEASE TO STOP'
                      : (model.isInitializing
                            ? 'PREPARING NATIVE TOOLS'
                            : 'PRESS AND HOLD TO TALK'),
                  textAlign: TextAlign.center,
                  style: _headlineStyle(context).copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandsFreeButton(BuildContext context) {
    final bool isPressed = model.isSessionActive;
    final bool isDisabled = !model.nativeFeaturesSupported;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: isDisabled ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              isPressed ? AppColors.primaryContainer : AppColors.primary,
              AppColors.primaryContainer,
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(34),
            onTap: isDisabled
                ? null
                : () {
                    unawaited(
                      model.isSessionActive
                          ? model.stopListening(stopSpeechOutput: true)
                          : model.startListening(),
                    );
                  },
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 560),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    isPressed ? Icons.stop_circle_rounded : Icons.mic_rounded,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      isPressed
                          ? 'STOP HANDS-FREE'
                          : (model.isInitializing
                                ? 'PREPARING NATIVE TOOLS'
                                : 'START HANDS-FREE'),
                      textAlign: TextAlign.center,
                      style: _headlineStyle(context).copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryDockButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurface,
        backgroundColor: AppColors.surfaceContainer.withValues(alpha: 0.9),
        side: BorderSide(color: AppColors.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: _bodyStyle(
          context,
        ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  Widget _buildSurfaceCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(24),
    double minHeight = 0,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _showLanguagePickerSheet({
    required BuildContext context,
    required String title,
    required LanguageOption currentValue,
    required Future<void> Function(LanguageOption value) onSelected,
  }) async {
    final LanguageOption? nextValue =
        await showModalBottomSheet<LanguageOption>(
          context: context,
          backgroundColor: AppColors.surfaceContainerLow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$title language',
                      style: _headlineStyle(
                        context,
                      ).copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: model.supportedLanguages.length,
                        separatorBuilder: (_, int index) =>
                            const SizedBox(height: 6),
                        itemBuilder: (BuildContext context, int index) {
                          final LanguageOption option =
                              model.supportedLanguages[index];
                          final bool isSelected = option == currentValue;

                          return Material(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => Navigator.of(context).pop(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        option.label,
                                        style: _bodyStyle(context).copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_rounded,
                                        color: AppColors.primary,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

    if (nextValue != null && nextValue != currentValue && mounted) {
      await onSelected(nextValue);
    }
  }

  TextStyle _headlineStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.headlineSmall!.copyWith(color: AppColors.onSurface);
  }

  TextStyle _bodyStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(color: AppColors.onSurface);
  }

  TextStyle _labelStyle(BuildContext context) {
    return Theme.of(
      context,
    ).textTheme.labelSmall!.copyWith(color: AppColors.outline);
  }
}
