import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/chat_message.dart';
import '../../../core/theme/app_theme.dart';
import '../../features/chat/presentation/chat_actions.dart'; // ignore: directives_ordering
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isThinking;
  final String? streamingContent;
  final String? thinkingMessage;
  final Function(String, Map<String, dynamic>)? onActionPressed;

  const ChatBubble({
    super.key,
    required this.message,
    this.isThinking = false,
    this.streamingContent,
    this.thinkingMessage,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == ChatMessageRole.user;

    if (isThinking &&
        !isUser &&
        (message.content == null || message.content!.isEmpty) &&
        (streamingContent == null || streamingContent!.isEmpty)) {
      return _buildThinkingBubble(context, theme);
    }

    final content = (streamingContent != null && streamingContent!.isNotEmpty)
        ? streamingContent!
        : (message.content ?? '');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 64 : 16,
          right: isUser ? 16 : 64,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isUser
                    ? null
                    : Border.all(color: const Color(0xFFE8EAED)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (content.isNotEmpty)
                    (streamingContent != null && streamingContent!.isNotEmpty)
                        ? _StreamingText(
                            text: content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurface,
                              height: 1.5,
                            ),
                          )
                        : Text(
                            content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isUser ? Colors.white : AppTheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                  if (message.actions != null &&
                      message.actions!.isNotEmpty &&
                      !isUser)
                    _buildActionsSafe(context, theme, message.actions!),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                message.createdAt != null
                    ? DateFormat('h:mm a').format(message.createdAt!)
                    : 'Now',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 250.ms).slideY(begin: 0.04, end: 0),
    );
  }

  Widget _buildActionsSafe(
    BuildContext context,
    ThemeData theme,
    String actionsString,
  ) {
    try {
      final decoded = jsonDecode(actionsString);
      if (decoded is List) {
        return _buildActions(context, theme, decoded);
      }
    } catch (_) {}
    return const SizedBox.shrink();
  }

  Widget _buildActions(
    BuildContext context,
    ThemeData theme,
    List<dynamic> actions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions.map<Widget>((action) {
        final actionType = action['type'] as String?;
        final actionData = (action['data'] as Map<String, dynamic>?) ?? {};
        if (actionType == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _buildActionWidget(context, actionType, actionData),
        );
      }).toList(),
    );
  }

  Widget _buildActionWidget(
    BuildContext context,
    String type,
    Map<String, dynamic> data,
  ) {
    switch (type) {
      case 'LOCATION_REQUEST':
        return LocationRequestAction(
          data: data,
          onUpdateLocation: (locData) =>
              onActionPressed?.call('LOCATION_UPDATED', locData),
        );
      case 'PROVIDER_SELECTION':
        return ProviderSelectionAction(
          data: data,
          onProviderSelected: (id) =>
              onActionPressed?.call('SELECT_PROVIDER', {'providerId': id}),
        );
      case 'PAYMENT_REQUEST':
        return PaymentRequestAction(
          data: data,
          onPay: (bookingId) =>
              onActionPressed?.call('PAY', {'bookingId': bookingId}),
        );
      case 'BOOKING_CARD':
        return BookingInfoCard(data: data);
      case 'CONFIRM_COMPLETION':
        return ConfirmCompletionAction(
          data: data,
          onResponse: (confirmed, reason) =>
              onActionPressed?.call('CONFIRM_COMPLETION', {
                'confirmed': confirmed,
                'bookingId': data['bookingId'],
                if (!confirmed && reason != null) 'reason': reason,
              }),
        );
      case 'REVIEW_REQUEST':
        return ReviewRequestAction(
          data: data,
          onReview: (rating, comment) =>
              onActionPressed?.call('SUBMIT_REVIEW', {
                'rating': rating,
                if (comment != null && comment.isNotEmpty) 'comment': comment,
              }),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildThinkingBubble(BuildContext context, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 16, right: 64),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: const Color(0xFFE8EAED)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PulsingDots(),
            if (thinkingMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                thinkingMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ).animate().fade(duration: 300.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streaming text: fades in each new word individually
// ─────────────────────────────────────────────────────────────────────────────

class _StreamingText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const _StreamingText({required this.text, this.style});

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  String _stable = '';
  String _latest = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _updateContent(widget.text);
  }

  @override
  void didUpdateWidget(_StreamingText old) {
    super.didUpdateWidget(old);
    if (widget.text != old.text) _updateContent(widget.text);
  }

  void _updateContent(String text) {
    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      setState(() {
        _stable = '';
        _latest = '';
      });
      return;
    }
    if (words.length == 1) {
      setState(() {
        _stable = '';
        _latest = words.first;
      });
    } else {
      setState(() {
        _stable = '${words.take(words.length - 1).join(' ')} ';
        _latest = words.last;
      });
    }
    // Reset to 0 first so the new word starts fully transparent,
    // then animate to 1. Must happen after setState so the new word
    // is in the tree before the animation drives a rebuild.
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stable.isEmpty && _latest.isEmpty) return const SizedBox.shrink();
    // Resolve the actual text color from the inherited style so we can
    // animate its alpha without WidgetSpan layout artifacts.
    final resolvedColor =
        DefaultTextStyle.of(context).style.merge(widget.style).color ??
        Colors.black;

    return AnimatedBuilder(
      animation: _fade,
      builder: (context, _) {
        return Text.rich(
          TextSpan(
            style: widget.style,
            children: [
              if (_stable.isNotEmpty) TextSpan(text: _stable),
              if (_latest.isNotEmpty)
                TextSpan(
                  text: _latest,
                  style: TextStyle(
                    color: resolvedColor.withValues(alpha: _fade.value),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * math.sin(t * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(
                      alpha: 0.5 + 0.5 * scale,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
