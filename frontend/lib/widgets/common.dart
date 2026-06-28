import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/format.dart';

class Avatar extends StatelessWidget {
  final String name; final Color color; final double size;
  const Avatar(this.name, this.color, {this.size = 44, super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * .3)),
        alignment: Alignment.center,
        child: Text(initials(name), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * .36)),
      );
}

class StatusPill extends StatelessWidget {
  final String state; // overdue|due-today|due-tom|upcoming|completed|settled
  final String? label;
  const StatusPill(this.state, {this.label, super.key});
  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (state) {
      case 'overdue': bg = AppColors.overSoft; fg = AppColors.over; break;
      case 'due-today':
      case 'due-tom': bg = AppColors.dueSoft; fg = AppColors.due; break;
      case 'completed':
      case 'settled': bg = AppColors.paidSoft; fg = AppColors.paid; break;
      case 'borrow': bg = AppColors.borrowSoft; fg = AppColors.borrowInk; break;
      default: bg = AppColors.primarySoft; fg = AppColors.primaryInk;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label ?? dueLabel(state),
          style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: .3)),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child; final EdgeInsets padding; final VoidCallback? onTap;
  const AppCard({required this.child, this.padding = const EdgeInsets.all(14), this.onTap, super.key});
  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Material(
      type: MaterialType.canvas,
      color: cardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: lineColor(context))),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title; final Widget? trailing;
  const SectionHeader(this.title, {this.trailing, super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 11),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          if (trailing != null) trailing!,
        ]),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon; final String text;
  const EmptyState(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
        child: Column(children: [
          Container(width: 64, height: 64,
              decoration: BoxDecoration(color: cardColor(context), borderRadius: BorderRadius.circular(20), border: Border.all(color: lineColor(context))),
              child: Icon(icon, color: mutedColor(context))),
          const SizedBox(height: 14),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: mutedColor(context), fontWeight: FontWeight.w500)),
        ]),
      );
}

class ErrorBox extends StatelessWidget {
  final Object error;
  const ErrorBox(this.error, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, color: AppColors.over, size: 40),
          const SizedBox(height: 12),
          Text('Could not reach the server.', style: TextStyle(color: mutedColor(context), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Check your API URL in core/api_client.dart',
              textAlign: TextAlign.center, style: TextStyle(color: mutedColor(context), fontSize: 12)),
        ]),
      );
}

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  ));
}
