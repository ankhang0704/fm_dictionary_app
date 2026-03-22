import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = DatabaseService.getSettings();
  }

  void _updateSettings() async {
    await DatabaseService.saveSettings(_settings);
    setState(() {});
  }

  void _showNameDialog() {
    final controller = TextEditingController(text: _settings.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter your name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _settings.userName = controller.text;
              _updateSettings();
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _resetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text(
          'This will clear all your learned words and Anki data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
              for (var word in wordBox.values) {
                word.isLearned = false;
                word.wrongCount = 0;
                word.repetitions = 0;
                word.interval = 0;
                await word.save();
              }
               if (!context.mounted) return; 
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset successfully!')),
              );
            },
            child: const Text('RESET', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'PROFILE',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('User Name'),
            trailing: Text(
              _settings.userName,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _showNameDialog,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),
          const Text(
            'AUDIO',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 20),
              const SizedBox(width: 12),
              const Text('TTS Speed'),
              const Spacer(),
              Text(
                '${_settings.ttsSpeed.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          Slider(
            value: _settings.ttsSpeed,
            min: 0.5,
            max: 1.5,
            activeColor: Colors.black,
            onChanged: (val) {
              _settings.ttsSpeed = val;
              _updateSettings();
            },
          ),
          const Divider(height: 48),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: Colors.red,
            ),
            title: const Text(
              'Reset Progress',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Clear all learning history'),
            onTap: _resetProgress,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
