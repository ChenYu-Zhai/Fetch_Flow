// lib/screens/settings_screen.dart
import 'package:featch_flow/providers/auth_provider.dart';
import 'package:featch_flow/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _civitaiTokenController;
  late final TextEditingController _rule34TokenController;
  late final TextEditingController _rule34UserIdController;

  bool isPickingPath = false;
  @override
  void initState() {
    super.initState();
    final initialAuthState = ref.read(authProvider);
    _civitaiTokenController = TextEditingController(
      text: initialAuthState.civitaiToken,
    );
    _rule34TokenController = TextEditingController(
      text: initialAuthState.rule34Token,
    );
    _rule34UserIdController = TextEditingController(
      text: initialAuthState.rule34UserId,
    );
    debugPrint('[SettingsScreen] Initialized with existing settings.');
  }

  @override
  void dispose() {
    _civitaiTokenController.dispose();
    _rule34TokenController.dispose();
    _rule34UserIdController.dispose();
    super.dispose();
    debugPrint('[SettingsScreen] Disposed.');
  }

  void _saveSettings() async {
    // If the focus is on an input field, unfocus it first to hide the keyboard.
    // 如果焦点在输入框，先取消焦点，这样可以收起键盘。
    FocusScope.of(context).unfocus();
    debugPrint('[SettingsScreen] Saving settings...');

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
    debugPrint('[SettingsScreen] Settings saved.');
  }

  void _pickDownloadPath() async {
    // Update the state to show a loading animation before starting to pick.
    // 开始选择前，更新状态以显示加载动画。
    setState(() {
      isPickingPath = true;
    });

    String? selectedDirectory;
    try {
      debugPrint('[SettingsScreen] Picking download path...');
      selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        debugPrint(
          '[SettingsScreen] Selected download path: $selectedDirectory',
        );
        ref.read(downloadPathProvider.notifier).setPath(selectedDirectory);
      } else {
        debugPrint('[SettingsScreen] Download path picking cancelled.');
      }
    } catch (e) {
      debugPrint('[SettingsScreen] Error picking path: $e');
    } finally {
      // Restore the state at the end, whether it was successful, failed, or cancelled.
      // Use `if (mounted)` to ensure the widget is still in the tree.
      // 无论成功、失败还是取消，最后都要将状态恢复。
      // 使用 `if (mounted)` 确保 Widget 仍然在树上。
      if (mounted) {
        setState(() {
          isPickingPath = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var downloadPath = ref.watch(downloadPathProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          8.0,
          8.0,
          8.0,
          80.0,
        ),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Appearance'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
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
                          debugPrint(
                            '[SettingsScreen] Grid columns changed to: ${newSelection.first}',
                          );
                          ref
                              .read(crossAxisCountNotifierProvider.notifier)
                              .setCount(newSelection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildSectionHeader('Downloads'),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Download Location'),
                  subtitle: downloadPath.isEmpty
                      ? Text(
                          'The default download path is the Download folder.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Text(
                          downloadPath,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: isPickingPath
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.folder_open),
                          onPressed: _pickDownloadPath,
                          tooltip: 'Choose Download Path',
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Authentication'),
                _buildSection('Civitai'),
                _buildTextFieldTile(
                  controller: _civitaiTokenController,
                  labelText: 'API Token',
                  isObscure: true,
                ),
                const Divider(height: 1),
                _buildSection('Rule34'),
                _buildTextFieldTile(
                  controller: _rule34TokenController,
                  labelText: 'API Key (api_key)',
                  isObscure: true,
                ),
                _buildTextFieldTile(
                  controller: _rule34UserIdController,
                  labelText: 'User ID (user_id)',
                ),
              ],
            ),
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
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
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
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        obscureText: isObscure,
      ),
    );
  }
}
