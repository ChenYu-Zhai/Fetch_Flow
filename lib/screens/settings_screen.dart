// lib/screens/settings_screen.dart

import 'dart:async';
import 'package:featch_flow/providers/auth_provider.dart';
import 'package:featch_flow/providers/settings_provider.dart';
import 'package:featch_flow/providers/unified_gallery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/legacy.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _civitaiTokenController;
  late final TextEditingController _rule34TokenController;
  late final TextEditingController _rule34UserIdController;

  @override
  void initState() {
    super.initState();
    final initialAuthState = ref.read(authProvider);
    _civitaiTokenController = TextEditingController(text: initialAuthState.civitaiToken);
    _rule34TokenController = TextEditingController(text: initialAuthState.rule34Token);
    _rule34UserIdController = TextEditingController(text: initialAuthState.rule34UserId);
    
    // 初始化所有 Slider 值为持久化值
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sliderValueProvider.notifier).state = 
        ref.read(prefetchThresholdNotifierProvider);
    });
  }

  @override
  void dispose() {
    _civitaiTokenController.dispose();
    _rule34TokenController.dispose();
    _rule34UserIdController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    FocusScope.of(context).unfocus();
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.updateCivitaiToken(_civitaiTokenController.text);
    await authNotifier.updateRule34Credentials(
      _rule34TokenController.text,
      _rule34UserIdController.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  void _pickDownloadPath() async {
    setState(() => isPickingPath = true);
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        ref.read(downloadPathProvider.notifier).setPath(selectedDirectory);
      }
    } finally {
      if (mounted) setState(() => isPickingPath = false);
    }
  }

  // ✅ 通用 Slider 构建器
  Widget _buildSliderTile<T extends StateNotifier<dynamic>>({
    required String title,
    required StateNotifierProvider<T, dynamic> provider,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    ValueChanged<double>? onChangeEnd,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              Consumer(
                builder: (context, ref, child) {
                  final value = ref.watch(provider);
                  return Text(
                    '${value.toInt()}${unit.isNotEmpty ? ' $unit' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
          Consumer(
            builder: (context, ref, child) {
              final value = ref.watch(provider);
              return Slider(
                value: value.toDouble(),
                min: min,
                max: max,
                divisions: divisions,
                label: value.toString(),
                onChanged: (newValue) {
                  final notifier = ref.read(provider.notifier);
                  if (provider == prefetchThresholdNotifierProvider) {
                    (notifier as PrefetchThresholdNotifier).setThreshold(newValue.toInt());
                  } else if (provider == cardHeightProvider) {
                    (notifier as CardHeightNotifier).setHeight(newValue);
                  } else if (provider == preloadDelayProvider) {
                    (notifier as PreloadDelayNotifier).setDelay(newValue.toInt());
                  } else if (provider == crossAxisCountNotifierProvider) {
                    (notifier as CrossAxisCountNotifier).setCount(newValue.toInt());
                  }
                },
                onChangeEnd: onChangeEnd,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildTextFieldTile({
    required TextEditingController controller,
    required String labelText,
    bool isObscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: labelText, border: const OutlineInputBorder(), isDense: true),
        obscureText: isObscure,
      ),
    );
  }

  bool isPickingPath = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: [
        IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Performance 配置
          Card(child: Column(children: [
            _buildSectionHeader('Performance'),
            _buildSliderTile(title: 'Card Height', provider: cardHeightProvider, min: 200, max: 800, divisions: 10, unit: 'px'),
            _buildSliderTile(title: 'Preload Delay', provider: preloadDelayProvider, min: 100, max: 1000, divisions: 9, unit: 'ms'),
            _buildSliderTile(title: 'Posts per Page', provider: prefetchThresholdNotifierProvider, min: 20, max: 200, divisions: 9, unit: ''),
          ])),
          
          const SizedBox(height: 16),
          
          // Appearance 配置
          Card(child: Column(children: [
            _buildSectionHeader('Appearance'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(children: [
                const Expanded(child: Text('Grid Columns')),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 3, label: Text('3')),
                    ButtonSegment(value: 4, label: Text('4')),
                    ButtonSegment(value: 6, label: Text('6')),
                    ButtonSegment(value: 8, label: Text('8')),
                  ],
                  selected: {ref.watch(crossAxisCountNotifierProvider)},
                  onSelectionChanged: (newSelection) {
                    ref.read(crossAxisCountNotifierProvider.notifier).setCount(newSelection.first);
                  },
                ),
              ]),
            ),
          ])),
          
          const SizedBox(height: 16),
          
          // Downloads 配置
          Card(child: Column(children: [
            _buildSectionHeader('Downloads'),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Download Location'),
              subtitle: ref.watch(downloadPathProvider).isEmpty
                  ? Text('Default: Downloads folder', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontStyle: FontStyle.italic))
                  : Text(ref.watch(downloadPathProvider), overflow: TextOverflow.ellipsis),
              trailing: isPickingPath
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: _pickDownloadPath,
                      tooltip: 'Choose Download Path',
                    ),
            ),
          ])),
          
          const SizedBox(height: 16),
          
          // Authentication 配置
          Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildSectionHeader('Authentication'),
            _buildSection('Civitai'),
            _buildTextFieldTile(controller: _civitaiTokenController, labelText: 'API Token', isObscure: true),
            const Divider(height: 1),
            _buildSection('Rule34'),
            _buildTextFieldTile(controller: _rule34TokenController, labelText: 'API Key (api_key)', isObscure: true),
            _buildTextFieldTile(controller: _rule34UserIdController, labelText: 'User ID (user_id)'),
          ])),
        ],
      ),
    );
  }
}