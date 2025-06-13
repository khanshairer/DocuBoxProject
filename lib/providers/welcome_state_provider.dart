import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final welcomeSeenProvider = AsyncNotifierProvider<WelcomeSeenNotifier, bool>(
  WelcomeSeenNotifier.new,
);

class WelcomeSeenNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenWelcome') ?? false;
  }

  Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);
    state = const AsyncValue.data(true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasSeenWelcome');
    state = const AsyncValue.data(false);
  }
}
