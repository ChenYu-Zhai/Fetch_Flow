// lib/widgets/civitai_filter_panel.dart

import 'package:featch_flow/models/civitai_filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CivitaiFilterPanel extends StatefulWidget {
  final CivitaiFilterState currentFilters;
  final ValueChanged<CivitaiFilterState> onFiltersChanged;

  const CivitaiFilterPanel({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<CivitaiFilterPanel> createState() => _CivitaiFilterPanelState();
}

class _CivitaiFilterPanelState extends State<CivitaiFilterPanel> {
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.currentFilters.username,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CivitaiFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the external state changes (e.g., clearing search), update the TextField accordingly.
    // 如果外部状态变化（例如清空搜索），同步更新 TextField。
    if (widget.currentFilters.username != _usernameController.text) {
      _usernameController.text = widget.currentFilters.username ?? '';
    }
  }

  void _handleFilterChange(CivitaiFilterState newFilters) {
    debugPrint('[CivitaiFilterPanel] Filters changed: $newFilters');
    widget.onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username input field.
          // 用户名输入框。
          SizedBox(
            width: 160,
            child: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
              onSubmitted: (value) {
                _handleFilterChange(
                  widget.currentFilters.copyWith(username: value),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Model ID input field.
          // Model ID 输入框。
          SizedBox(
            width: 120,
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Model ID',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
              onSubmitted: (value) {
                final int? modelId = int.tryParse(value);
                _handleFilterChange(
                  widget.currentFilters.copyWith(modelId: modelId),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Sort order dropdown menu.
          // 排序方式下拉菜单。
          _buildDropdown<CivitaiSort>(
            value: widget.currentFilters.sort,
            items: CivitaiSort.values,
            onChanged: (v) =>
                _handleFilterChange(widget.currentFilters.copyWith(sort: v!)),
          ),

          const SizedBox(width: 12),

          // Time range dropdown menu.
          // 时间范围下拉菜单。
          _buildDropdown<CivitaiPeriod>(
            value: widget.currentFilters.period,
            items: CivitaiPeriod.values,
            onChanged: (v) =>
                _handleFilterChange(widget.currentFilters.copyWith(period: v!)),
          ),

          const SizedBox(width: 12),

          // NSFW settings dropdown menu.
          // NSFW 设置下拉菜单。
          _buildDropdown<CivitaiNsfw>(
            value: widget.currentFilters.nsfw,
            items: CivitaiNsfw.values,
            onChanged: (v) =>
                _handleFilterChange(widget.currentFilters.copyWith(nsfw: v!)),
          ),
        ],
      ),
    );
  }

  // Generic dropdown menu builder method.
  // 通用的下拉菜单构建方法。
  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    return DropdownButton<T>(
      value: value,
      items: items.map((item) {
        final text = (item as Enum).name;
        return DropdownMenuItem<T>(value: item, child: Text(text));
      }).toList(),
      onChanged: onChanged,
      // Ensure dropdown menu styling matches the app theme.
      // 让下拉菜单样式来自主题。
      dropdownColor: theme.canvasColor,
      style: theme.textTheme.bodyMedium,
      iconEnabledColor: theme.hintColor,
      underline: Container(),
    );
  }
}
