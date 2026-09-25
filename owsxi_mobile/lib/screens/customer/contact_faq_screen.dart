import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_brutal_widgets.dart';

class ContactFaqScreen extends StatefulWidget {
  const ContactFaqScreen({super.key});

  @override
  State<ContactFaqScreen> createState() => _ContactFaqScreenState();
}

class _ContactFaqScreenState extends State<ContactFaqScreen> {
  final _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _launchInstagram() async {
    final Uri uri = Uri.parse('https://www.instagram.com/owsxiii/');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch Instagram URL: $e');
    }
  }

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
          'CONTACT US & FAQ',
          style: AppTypography.headlineMedium(color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instagram Section
            Text(
              'INSTAGRAM COMMUNITY',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _launchInstagram,
              borderRadius: BorderRadius.circular(4),
              child: NeoBrutalContainer(
                backgroundColor: AppColors.secondaryFixed,
                borderColor: AppColors.onSecondaryFixed,
                shadowColor: AppColors.onSecondaryFixed,
                shadowOffset: const Offset(4, 4),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(color: AppColors.onSecondaryFixed, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.onSecondaryFixed,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@OWSXIII',
                            style: AppTypography.headlineMedium(color: AppColors.onSecondaryFixed),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Follow us on Instagram for latest drops & updates',
                            style: AppTypography.bodySmall(color: AppColors.onSecondaryFixed),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      color: AppColors.onSecondaryFixed,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'FREQUENTLY ASKED QUESTIONS',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 14),

            _faqItem(
              'Are the stickers waterproof and dishwasher safe?',
              'Yes! All Owsxi stickers feature a heavy duty vinyl substrate with UV-laminated retro gloss coating.',
            ),
            _faqItem(
              'How long does standard shipping take?',
              'Orders are processed within 24 hours. Standard domestic delivery takes 2 to 4 business days.',
            ),
            _faqItem(
              'Do you accept custom scrapbook commission orders?',
              'We accept limited custom zine & art print drops at the start of every month! Follow our newsletter for drops.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoBrutalContainer(
        backgroundColor: AppColors.surfaceContainerLowest,
        borderColor: AppColors.onSecondaryFixed,
        shadowColor: AppColors.onSecondaryFixed,
        shadowOffset: const Offset(3, 3),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.help_outline,
                  size: 20,
                  color: AppColors.primaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.toUpperCase(),
                    style: AppTypography.labelBold(color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              answer,
              style: AppTypography.bodySmall(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
