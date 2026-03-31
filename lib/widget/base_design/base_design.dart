import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class BaseDesign extends StatelessWidget {
  const BaseDesign({
    super.key,
    required this.children,
    this.leftTitle,
    this.leading,
    this.viewBackBtn = true,
    this.bottomWidget,
    this.bodyPadding = const EdgeInsets.fromLTRB(24, 24, 24, 24),
    this.backgroundColor,
    this.bottomOverlayHeight = 320,
  });

  final List<Widget> children;
  final String? leftTitle;
  final Widget? leading;
  final bool viewBackBtn;
  final Widget? bottomWidget;
  final EdgeInsets bodyPadding;
  final Color? backgroundColor;
  final double bottomOverlayHeight;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets mediaPadding = MediaQuery.paddingOf(context);
    const double topBarHeight = 72;
    final double contentTop = mediaPadding.top + topBarHeight + bodyPadding.top;
    final double contentBottom =
        bodyPadding.bottom +
        (bottomWidget == null ? mediaPadding.bottom : bottomOverlayHeight);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: _buildBackground()),
            ListView.separated(
              padding: EdgeInsets.fromLTRB(
                bodyPadding.left,
                contentTop,
                bodyPadding.right,
                contentBottom,
              ),
              itemBuilder: (_, int index) => children[index],
              separatorBuilder: (_, int index) => const SizedBox(height: 24),
              itemCount: children.length,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(
                context,
                topPadding: mediaPadding.top,
                height: topBarHeight,
              ),
            ),
            if (bottomWidget != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomDock(
                  context,
                  bottomPadding: mediaPadding.bottom,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[AppColors.surface, AppColors.background],
            ),
          ),
        ),
        Positioned(
          right: -140,
          top: 240,
          width: 220,
          height: 420,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.onSurface.withValues(alpha: 0.012),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(
    BuildContext context, {
    required double topPadding,
    required double height,
  }) {
    final bool canPop = viewBackBtn && Navigator.of(context).canPop();
    final TextStyle titleStyle =
        Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          shadows: const <Shadow>[
            Shadow(
              color: Color(0x66000000),
              blurRadius: 14,
              offset: Offset(0, 3),
            ),
          ],
        ) ??
        TextStyle(
          color: AppColors.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        );

    return Container(
      height: topPadding + height,
      padding: EdgeInsets.fromLTRB(24, topPadding + 6, 24, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.onSurface.withValues(alpha: 0.03),
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 44,
              height: 44,
              child: canPop
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    )
                  : leading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Text(
              leftTitle ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomDock(
    BuildContext context, {
    required double bottomPadding,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 14, 24, 10 + bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.04)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: bottomWidget,
    );
  }
}
