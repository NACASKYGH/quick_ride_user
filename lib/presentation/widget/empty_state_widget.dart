import '../../utils/app_colors.dart';
import '../../utils/extensions.dart';
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.title = '',
    this.desc = '',
    this.showGreyLogo = true,
    this.padding = EdgeInsets.zero,
  });
  final String title;
  final String desc;
  final bool showGreyLogo;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: showGreyLogo,
              child: Image.asset(
                'assets/png/full-transparent-white-logo.png',
                width: 120,
                color: AppColors.grey300,
              ),
            ),
            Visibility(
              visible: title.isNotEmpty,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: AppColors.grey300,
                ),
              ),
            ),
            Visibility(
              visible: desc.isNotEmpty,
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.grey300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
