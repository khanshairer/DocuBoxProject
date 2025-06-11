import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_settings_provider.dart'; // Import theme settings provider
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(
      themeSettingsProvider,
    ); // Watch for theme state
    final themeNotifier = ref.read(
      themeSettingsProvider.notifier,
    ); // Access notifier methods

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Mode Toggle
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Theme',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Light Theme'),
                      Switch(
                        value: themeSettings.themeMode == ThemeMode.dark,
                        onChanged: (bool value) {
                          themeNotifier.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      const Text('Dark Theme'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: ${themeSettings.themeMode == ThemeMode.light ? 'Light' : 'Dark'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // Brightness Slider
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brightness',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: themeSettings.brightnessFactor,
                    min: 0.5, // Minimum brightness (50%)
                    max: 1.5, // Maximum brightness (150%)
                    divisions: 10,
                    label: '${(themeSettings.brightnessFactor * 100).round()}%',
                    onChanged: (double value) {
                      themeNotifier.setBrightness(value);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                  Center(
                    child: Text(
                      'Current Brightness: ${(themeSettings.brightnessFactor * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Font Size Adjustment
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: themeNotifier.decreaseFontSize,
                        child: const Icon(Icons.remove),
                      ),
                      Text(
                        '${(themeSettings.fontSizeFactor * 100).round()}%',
                        style:
                            Theme.of(context)
                                .textTheme
                                .headlineSmall, // Use a headline style for prominence
                      ),
                      ElevatedButton(
                        onPressed: themeNotifier.increaseFontSize,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Adjust text size for better readability.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Example of other settings (add more as needed)
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Settings'),
              trailing: Switch(
                value: true, // Example value
                onChanged: (bool value) {
                  // Implement notification toggle logic
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                // Navigate to a more detailed notification settings page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Go to detailed notification settings'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
