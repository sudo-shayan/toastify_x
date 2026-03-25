import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

// ================= ENUMS =================

/// Types of toasts available in ToastifyX.
enum ToastType { success, error, warning, info, loading }

/// Physical position of the toast on the screen.
enum ToastPosition { top, center, bottom }

/// visual styling of the toast container.
enum ToastStyle { modern, minimal, glass, flat }

/// Entry/Exit animation types.
enum AnimationType { slide, scale, fade, bounce }

// ================= GLOBAL =================

/// Global navigator key required for showing toasts without BuildContext.
final GlobalKey<NavigatorState> toastNavigatorKey = GlobalKey<NavigatorState>();

// ================= MAIN =================

/// Main class for interacting with ToastifyX.
class ToastifyX {
  static final List<_ToastRequest> _queue = [];
  static bool _isShowing = false;

  /// Displays a toast notification with the specified parameters.
  /// 
  /// - [message]: The text content to display.
  /// - [type]: Predefined toast type (success, error, etc.) for icons and colors.
  /// - [position]: Where on the screen to show the toast.
  /// - [style]: The visual theme (glassmorphism, flat, etc.).
  /// - [animationType]: How the toast enters/exits.
  /// - [duration]: How long the toast stays visible.
  /// - [backgroundColor]: Custom color to override the type-based default.
  /// - [customIcon]: Custom icon to override the type-based default.
  /// - [showProgress]: Adds a loading indicator and prevents auto-dismiss.
  static void show(
    BuildContext? context, {
    required String message,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.top,
    ToastStyle style = ToastStyle.modern,
    AnimationType animationType = AnimationType.slide,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    IconData? customIcon,
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    String? actionLabel,
    VoidCallback? onAction,
    bool enableBlur = false,
    bool showProgress = false,
  }) {
    final overlay = toastNavigatorKey.currentState!.overlay!;

    final request = _ToastRequest(
      overlay: overlay,
      message: message,
      type: type,
      position: position,
      style: style,
      animationType: animationType,
      duration: duration,
      backgroundColor: backgroundColor,
      customIcon: customIcon,
      textStyle: textStyle,
      padding: padding,
      margin: margin,
      actionLabel: actionLabel,
      onAction: onAction,
      enableBlur: enableBlur,
      showProgress: showProgress,
    );

    // Queue the toast to prevent overlaps
    _queue.add(request);
    _showNext();
  }

  /// Manages the queue and shows the next toast if nothing is currently showing.
  static void _showNext() {
    if (_isShowing || _queue.isEmpty) return;

    _isShowing = true;
    final req = _queue.removeAt(0);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        request: req,
        overlayEntry: entry,
        onDismissed: () {
          _isShowing = false;
          _showNext();
        },
      ),
    );

    req.overlay.insert(entry);
  }
}

// ================= MODEL =================
class _ToastRequest {
  final OverlayState overlay;
  final String message;
  final ToastType type;
  final ToastPosition position;
  final ToastStyle style;
  final AnimationType animationType;
  final Duration duration;
  final Color? backgroundColor;
  final IconData? customIcon;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool enableBlur;
  final bool showProgress;

  _ToastRequest({
    required this.overlay,
    required this.message,
    required this.type,
    required this.position,
    required this.style,
    required this.animationType,
    required this.duration,
    this.backgroundColor,
    this.customIcon,
    this.textStyle,
    this.padding,
    this.margin,
    this.actionLabel,
    this.onAction,
    this.enableBlur = false,
    this.showProgress = false,
  });
}

// ================= WIDGET =================
class _ToastWidget extends StatefulWidget {
  final _ToastRequest request;
  final OverlayEntry overlayEntry;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.request,
    required this.overlayEntry,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Calculate the start offset for slide animations based on position
    Offset beginOffset = const Offset(0, -0.2);
    if (widget.request.position == ToastPosition.bottom) {
      beginOffset = const Offset(0, 0.2);
    } else if (widget.request.position == ToastPosition.center) {
      beginOffset = const Offset(0, 0.0);
    }

    // Configure the slide animation (Bounce vs Ease)
    _slide = Tween<Offset>(
      begin: widget.request.animationType == AnimationType.bounce
          ? (widget.request.position == ToastPosition.bottom
              ? const Offset(0, 0.5)
              : const Offset(0, -0.5))
          : beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.request.animationType == AnimationType.bounce
          ? Curves.elasticOut
          : Curves.easeOut,
    ));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Auto-dismiss logic (disabled for loading/progress types)
    if (widget.request.type != ToastType.loading && !widget.request.showProgress) {
      Future.delayed(widget.request.duration, () async {
        if (mounted) {
          await _controller.reverse();
          if (widget.overlayEntry.mounted) {
            widget.overlayEntry.remove();
          }
          widget.onDismissed();
        }
      });
    }
  }

  IconData _getIcon() {
    if (widget.request.customIcon != null) return widget.request.customIcon!;
    switch (widget.request.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.loading:
        return Icons.hourglass_top;
      case ToastType.info:
        return Icons.info;
    }
  }

  Color _getColor() {
    if (widget.request.backgroundColor != null) return widget.request.backgroundColor!;
    switch (widget.request.type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.loading:
        return Colors.blueGrey;
      case ToastType.info:
        return Colors.blue;
    }
  }

  BoxDecoration _getStyle() {
    switch (widget.request.style) {
      case ToastStyle.glass:
        return BoxDecoration(
          color: Colors.white.withAlpha(128),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        );
      case ToastStyle.minimal:
        return BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        );
      case ToastStyle.flat:
        return BoxDecoration(color: _getColor());
      case ToastStyle.modern:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [_getColor(), _getColor().withAlpha(128)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.up,
      onDismissed: (_) async {
        await _controller.reverse();
        if (widget.overlayEntry.mounted) {
          widget.overlayEntry.remove();
        }
        widget.onDismissed();
      },
      child: Container(
        padding: widget.request.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: widget.request.margin ?? const EdgeInsets.all(0),
        decoration: _getStyle(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_getIcon(), color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.request.message,
                    style: widget.request.textStyle ?? const TextStyle(color: Colors.white),
                  ),
                ),
                if (widget.request.actionLabel != null)
                  TextButton(
                    onPressed: widget.request.onAction,
                    child: Text(
                      widget.request.actionLabel!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            if (widget.request.showProgress)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.request.enableBlur) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(widget.request.style == ToastStyle.flat ? 0 : 20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      );
    }

    Widget animatedChild;
    switch (widget.request.animationType) {
      case AnimationType.scale:
        animatedChild = ScaleTransition(scale: _scale, child: child);
        break;
      case AnimationType.fade:
        animatedChild = FadeTransition(opacity: _fade, child: child);
        break;
      case AnimationType.bounce:
      case AnimationType.slide:
        animatedChild = SlideTransition(position: _slide, child: child);
        break;
    }

    if (widget.request.animationType != AnimationType.fade) {
      animatedChild = FadeTransition(opacity: _fade, child: animatedChild);
    }

    return Positioned(
      top: widget.request.position == ToastPosition.top ? 60 : (widget.request.position == ToastPosition.center ? 0 : null),
      bottom: widget.request.position == ToastPosition.bottom ? 60 : (widget.request.position == ToastPosition.center ? 0 : null),
      left: 20,
      right: 20,
      child: widget.request.position == ToastPosition.center
          ? Center(child: Material(color: Colors.transparent, child: animatedChild))
          : Material(color: Colors.transparent, child: animatedChild),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}