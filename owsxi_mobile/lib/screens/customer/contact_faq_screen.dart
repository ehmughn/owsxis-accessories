import 'package:flutter/material.dart';
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

            const SizedBox(height: 28),

            Text(
              'SEND US A DIRECT MESSAGE',
              style: AppTypography.headlineMedium(color: AppColors.onSurface),
            ),
            const SizedBox(height: 14),

            NeoBrutalContainer(
              backgroundColor: AppColors.surfaceContainerLowest,
              borderColor: AppColors.onSecondaryFixed,
              shadowColor: AppColors.onSecondaryFixed,
              shadowOffset: const Offset(4, 4),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const NeoBrutalTextField(
                    label: 'Your Email Address',
                    hint: 'you@domain.com',
                  ),
                  const SizedBox(height: 12),
                  const NeoBrutalTextField(
                    label: 'Subject',
                    hint: 'Order question, bulk drop inquiry...',
                  ),
                  const SizedBox(height: 12),
                  NeoBrutalTextField(
                    label: 'Message',
                    hint: 'Write your inquiry here...',
                    controller: _msgController,
                  ),
                  const SizedBox(height: 20),
                  NeoBrutalButton(
                    label: 'DISPATCH MESSAGE',
                    icon: Icons.send,
                    backgroundColor: AppColors.primaryContainer,
                    textColor: AppColors.onPrimary,
                    shadowColor: AppColors.onSecondaryFixed,
                    fullWidth: true,
                    onPressed: () {
                      _msgController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.onSecondaryFixed,
                          content: Text(
                            'MESSAGE DISPATCHED! WE WILL REPLY SHORTLY.',
                            style: AppTypography.labelBold(color: AppColors.onPrimary),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
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
