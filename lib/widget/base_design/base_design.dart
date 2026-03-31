import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class BaseDesign extends StatelessWidget {
  const BaseDesign({
    super.key,
    required this.children,
    this.leftTitle,
    this.viewBackBtn = true,
    this.bottomWidget,
    this.bodyPadding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
    this.backgroundColor,
  });

  final List<Widget> children;
  final String? leftTitle;
  final bool viewBackBtn;
  final Widget? bottomWidget;
  final EdgeInsetsGeometry bodyPadding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.containerL0,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.containerL2,
              AppColors.containerL0,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: <Widget>[
                    if (viewBackBtn && Navigator.of(context).canPop())
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        leftTitle ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textHigh,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: bodyPadding,
                  itemBuilder: (_, int index) => children[index],
                  separatorBuilder: (_, index) => const SizedBox(height: 16),
                  itemCount: children.length,
                ),
              ),
              if (bottomWidget != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: bottomWidget!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
