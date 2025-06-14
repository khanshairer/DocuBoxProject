import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track whether notifications are enabled.
final notificationEnabledProvider = StateProvider<bool>((ref) => true);
