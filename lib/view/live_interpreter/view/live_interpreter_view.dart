import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../constants/app_colors.dart';
import '../../../extensions/int.dart';
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
    return Observer(
      builder: (BuildContext context) {
        return BaseDesign(
          leftTitle: 'Live Interpreter',
          viewBackBtn: false,
          bodyPadding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          bottomWidget: _buildPushToTalkDock(),
          children: <Widget>[
            _buildLanguageCard(),
            _buildTranscriptCard(
              title: 'Live transcript',
              subtitle: model.sourceLanguage.label,
              text: model.transcript,
              placeholder: model.handsFreeMode
                  ? 'Tap the mic once, speak, then pause for 2 seconds.'
                  : 'Press and hold the mic button, then speak.',
              accentColor: AppColors.primary,
              onSpeak: model.hasTranscript ? model.speakOriginalText : null,
              trailing: model.hasTranscript
                  ? IconButton.filledTonal(
                      onPressed: model.clearTranscript,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline_rounded),
                    )
                  : null,
              actionIcon: Icons.record_voice_over_rounded,
            ),
            _buildTranscriptCard(
              title: 'Translation',
              subtitle: '${model.targetLanguage.label} • Auto TTS',
              text: model.translatedText,
              placeholder: 'Translated text appears here.',
              accentColor: AppColors.warning,
              onSpeak: model.translatedText.trim().isNotEmpty
                  ? model.speakTranslatedText
                  : null,
              actionIcon: Icons.volume_up_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageCard() {
    return _buildSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Languages',
            style: TextStyle(
              color: AppColors.textHigh,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          12.spacerV,
          Row(
            children: <Widget>[
              Expanded(
                child: _buildLanguageDropdown(
                  title: 'From',
                  value: model.sourceLanguage,
                  onChanged: (LanguageOption? value) {
                    if (value != null) {
                      unawaited(model.changeSourceLanguage(value));
                    }
                  },
                ),
              ),
              8.spacerH,
              IconButton.filledTonal(
                onPressed: model.swapLanguages,
                icon: const Icon(Icons.swap_horiz_rounded),
                visualDensity: VisualDensity.compact,
              ),
              8.spacerH,
              Expanded(
                child: _buildLanguageDropdown(
                  title: 'To',
                  value: model.targetLanguage,
                  onChanged: (LanguageOption? value) {
                    if (value != null) {
                      unawaited(model.changeTargetLanguage(value));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String title,
    required LanguageOption value,
    required ValueChanged<LanguageOption?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: AppColors.textLow,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        8.spacerV,
        DropdownButtonFormField<LanguageOption>(
          initialValue: value,
          isExpanded: true,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.containerL2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.strokeDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.strokeDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          dropdownColor: AppColors.containerL1,
          style: TextStyle(
            color: AppColors.textHigh,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          iconEnabledColor: AppColors.textHigh,
          selectedItemBuilder: (BuildContext context) {
            return model.supportedLanguages.map((LanguageOption language) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  language.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: AppColors.textHigh,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList();
          },
          items: model.supportedLanguages.map((LanguageOption language) {
            return DropdownMenuItem<LanguageOption>(
              value: language,
              child: Text(
                language.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTranscriptCard({
    required String title,
    required String subtitle,
    required String text,
    required String placeholder,
    required Color accentColor,
    required IconData actionIcon,
    Future<void> Function()? onSpeak,
    Widget? trailing,
  }) {
    return _buildSurface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Icon(actionIcon, color: accentColor, size: 20),
                    8.spacerH,
                    Expanded(
                      child: Text(
                        '$title • $subtitle',
                        style: TextStyle(
                          color: AppColors.textHigh,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing case final Widget trailingWidget) ...<Widget>[
                8.spacerH,
                trailingWidget,
              ],
              if (onSpeak != null) ...<Widget>[
                8.spacerH,
                FilledButton.tonalIcon(
                  onPressed: onSpeak,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Speak'),
                ),
              ],
            ],
          ),
          12.spacerV,
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 112),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.containerL2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.25)),
            ),
            child: SelectableText(
              text.isEmpty ? placeholder : text,
              style: TextStyle(
                color: text.isEmpty ? AppColors.textLow : AppColors.textHigh,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPushToTalkDock() {
    final bool isPressed = model.isSessionActive;
    final bool isDisabled = !model.nativeFeaturesSupported;
    final Color accentColor = isPressed ? AppColors.warning : AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (model.errorText.isNotEmpty) ...<Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Text(
              model.errorText,
              style: TextStyle(
                color: AppColors.textHigh,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          12.spacerV,
        ],
        _buildModeSelector(),
        12.spacerV,
        Text(
          model.statusText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textMid,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        12.spacerV,
        if (model.handsFreeMode)
          _buildHandsFreeButton(
            accentColor: accentColor,
            isDisabled: isDisabled,
          )
        else
          Listener(
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: <Color>[
                    accentColor,
                    accentColor.withValues(alpha: 0.82),
                  ],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: isPressed ? 24 : 14,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    isPressed ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: AppColors.containerL0,
                    size: 22,
                  ),
                  10.spacerH,
                  Text(
                    isPressed
                        ? 'Release To Stop'
                        : (model.isInitializing
                              ? 'Preparing Native Tools'
                              : 'Press And Hold To Talk'),
                    style: TextStyle(
                      color: AppColors.containerL0,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!model.micPermissionGranted) ...<Widget>[
          12.spacerV,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: <Widget>[
              _buildCompactButton(
                icon: Icons.mic_rounded,
                label: 'Grant mic',
                onPressed: model.requestMicrophonePermission,
              ),
              _buildCompactButton(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onPressed: model.openPermissionSettings,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildModeButton(
            label: 'Hold',
            selected: !model.handsFreeMode,
            onPressed: () => unawaited(model.setHandsFreeMode(false)),
          ),
        ),
        8.spacerH,
        Expanded(
          child: _buildModeButton(
            label: 'Hands-free',
            selected: model.handsFreeMode,
            onPressed: () => unawaited(model.setHandsFreeMode(true)),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    if (selected) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.containerL0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildHandsFreeButton({
    required Color accentColor,
    required bool isDisabled,
  }) {
    return FilledButton.icon(
      onPressed: isDisabled
          ? null
          : () => unawaited(
              model.isSessionActive
                  ? model.stopListening(stopSpeechOutput: true)
                  : model.startListening(),
            ),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        backgroundColor: accentColor,
        foregroundColor: AppColors.containerL0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      icon: Icon(
        model.isSessionActive ? Icons.stop_circle_rounded : Icons.mic_rounded,
        size: 22,
      ),
      label: Text(
        model.isSessionActive
            ? 'Stop Hands-Free'
            : (model.isInitializing
                  ? 'Preparing Native Tools'
                  : 'Start Hands-Free'),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool filled = false,
  }) {
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[Icon(icon, size: 18), 6.spacerH, Text(label)],
    );

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: model.isSessionActive
              ? AppColors.warning
              : AppColors.primary,
          foregroundColor: AppColors.containerL0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: child,
    );
  }

  Widget _buildSurface({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.containerL1.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.strokeDefault),
      ),
      child: child,
    );
  }
}
