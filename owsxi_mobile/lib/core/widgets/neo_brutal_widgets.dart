import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Neo-Brutalist Container with sharp 0px border radius, heavy border, and hard offset box shadow.
class NeoBrutalContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double borderWidth;
  final Offset shadowOffset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const NeoBrutalContainer({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.surfaceContainerLowest,
    this.borderColor = AppColors.onSecondaryFixed,
    this.shadowColor = AppColors.tertiaryContainer,
    this.borderWidth = 3.5,
    this.shadowOffset = const Offset(4, 4),
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.zero,
        boxShadow: shadowOffset == Offset.zero
            ? []
            : [
                BoxShadow(
                  color: shadowColor,
                  offset: shadowOffset,
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Interactive Neo-Brutalist Button with tap depression micro-animation
class NeoBrutalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;
  final IconData? icon;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final bool fullWidth;

  const NeoBrutalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor = AppColors.primaryContainer,
    this.textColor = AppColors.onPrimary,
    this.borderColor = AppColors.onSecondaryFixed,
    this.shadowColor = AppColors.onSecondaryFixed,
    this.icon,
    this.borderWidth = 3.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.fullWidth = false,
  });

  @override
  State<NeoBrutalButton> createState() => _NeoBrutalButtonState();
}

class _NeoBrutalButtonState extends State<NeoBrutalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final offset = _isPressed ? const Offset(1, 1) : const Offset(4, 4);

    Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: widget.textColor, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label.toUpperCase(),
          style: AppTypography.labelBold(color: widget.textColor).copyWith(
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: Matrix4.translationValues(
          _isPressed ? 2 : 0,
          _isPressed ? 2 : 0,
          0,
        ),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? AppColors.surfaceContainerHigh
              : widget.backgroundColor,
          border: Border.all(color: widget.borderColor, width: widget.borderWidth),
          borderRadius: BorderRadius.zero,
          boxShadow: [
            BoxShadow(
              color: widget.onPressed == null
                  ? AppColors.outline
                  : widget.shadowColor,
              offset: offset,
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

/// Neo-Brutalist Text Input Field
class NeoBrutalTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;

  const NeoBrutalTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: AppTypography.labelBold(color: AppColors.onSurface),
          ),
          const SizedBox(height: 6),
        ],
        NeoBrutalContainer(
          backgroundColor: AppColors.surfaceContainerLowest,
          borderColor: AppColors.onSecondaryFixed,
          shadowColor: AppColors.onSecondaryFixed,
          shadowOffset: const Offset(3, 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: AppTypography.bodyMedium(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMedium(color: AppColors.outline),
              border: InputBorder.none,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppColors.onSurface)
                  : null,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTypography.labelSmall(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

/// High-contrast Neo-Brutalist Tag Badge / Chip
class NeoBrutalBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;

  const NeoBrutalBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.tertiaryFixed,
    this.textColor = AppColors.onTertiaryFixed,
    this.borderColor = AppColors.onSecondaryFixed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall(color: textColor).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Retro 24px Grid Background Painter
class GridBackgroundPainter extends CustomPainter {
  final Color gridColor;
  final double step;

  GridBackgroundPainter({
    this.gridColor = const Color.fromRGBO(15, 18, 80, 0.08),
    this.step = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wrapper Widget to display the Neo-Brutalist Grid Pattern behind page content
class GridBackground extends StatelessWidget {
  final Widget child;

  const GridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: GridBackgroundPainter(),
          ),
        ),
        child,
      ],
    );
  }
}
