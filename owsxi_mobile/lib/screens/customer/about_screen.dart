import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: AppColors.onSecondaryFixed, height: 4),
        ),
        title: Text(
          'ABOUT OWSXI STUDIO',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeoBrutalContainer(
              backgroundColor: AppColors.primaryContainer,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.tertiaryContainer,
              shadowOffset: const Offset(5, 5),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'OWSXI',
                    style: AppTypography.displayLarge(color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NOSTALGIC ART FOR MODERN SOULS',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelBold(color: AppColors.onPrimaryContainer),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'OUR MANIFESTO',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 10),
            Text(
              'Owsxi Studio was founded at the intersection of indie-sleaze nostalgia, brutalist design typography, and tactile physical craftsmanship. We create physical stickers, pins, zines, and art prints designed to survive on laptop lids, scrapbook pages, and studio walls.',
              style: AppTypography.bodyLarge(color: AppColors.onSurfaceVariant),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
