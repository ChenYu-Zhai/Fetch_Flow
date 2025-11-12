import 'dart:ui';

import 'package:featch_flow/models/civitai_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ 1. 定义一些常量，方便全局调整样式
const double kFilterItemHeight = 34.0;
const double kFilterItemSpacing = 8.0;
const BorderRadius kFilterItemBorderRadius = BorderRadius.all(Radius.circular(8.0));

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
  late final TextEditingController _modelIdController;
  
  // 用于处理清除按钮的焦点
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _modelIdFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentFilters.username);
    _modelIdController = TextEditingController(text: widget.currentFilters.modelId?.toString() ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _modelIdController.dispose();
    _usernameFocusNode.dispose();
    _modelIdFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CivitaiFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFilters.username != _usernameController.text) {
      _usernameController.text = widget.currentFilters.username ?? '';
    }
    final modelIdText = widget.currentFilters.modelId?.toString() ?? '';
    if (modelIdText != _modelIdController.text) {
      _modelIdController.text = modelIdText;
    }
  }

  void _handleFilterChange(CivitaiFilterState newFilters) {
    widget.onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Username input
          SizedBox(
            width: 160,
            height: kFilterItemHeight,
            child: _buildTextField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              hintText: 'Username',
              icon: Icons.person_outline,
              onSubmitted: (value) {
                _handleFilterChange(
                  widget.currentFilters.copyWith(username: value.isNotEmpty ? value : null),
                );
              },
              onClear: () {
                _usernameController.clear();
                _handleFilterChange(widget.currentFilters.copyWith(username: null));
              },
            ),
          ),
          const SizedBox(width: kFilterItemSpacing),

          // Model ID input
          SizedBox(
            width: 120,
            height: kFilterItemHeight,
            child: _buildTextField(
              controller: _modelIdController,
              focusNode: _modelIdFocusNode,
              hintText: 'Model ID',
              icon: Icons.tag,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (value) {
                _handleFilterChange(
                  widget.currentFilters.copyWith(modelId: int.tryParse(value)),
                );
              },
              onClear: () {
                _modelIdController.clear();
                _handleFilterChange(widget.currentFilters.copyWith(modelId: null));
              },
            ),
          ),
          const SizedBox(width: kFilterItemSpacing),

          // Dropdowns
          _buildDropdown<CivitaiSort>(
            value: widget.currentFilters.sort,
            items: CivitaiSort.values,
            onChanged: (v) => _handleFilterChange(widget.currentFilters.copyWith(sort: v!)),
          ),
          const SizedBox(width: kFilterItemSpacing),
          _buildDropdown<CivitaiPeriod>(
            value: widget.currentFilters.period,
            items: CivitaiPeriod.values,
            onChanged: (v) => _handleFilterChange(widget.currentFilters.copyWith(period: v!)),
          ),
          const SizedBox(width: kFilterItemSpacing),
          _buildDropdown<CivitaiNsfw>(
            value: widget.currentFilters.nsfw,
            items: CivitaiNsfw.values,
            onChanged: (v) => _handleFilterChange(widget.currentFilters.copyWith(nsfw: v!)),
          ),
        ],
      ),
    );
  }

  // ✅ 2. 全新的 TextField 构建方法
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required ValueChanged<String> onSubmitted,
    required VoidCallback onClear,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13, color: theme.hintColor.withOpacity(0.6)),
            prefixIcon: Icon(icon, size: 16, color: theme.hintColor),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: onClear,
                    splashRadius: 16,
                    color: theme.hintColor,
                  )
                : null,
            filled: true,
            fillColor: theme.cardColor.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: const OutlineInputBorder(
              borderRadius: kFilterItemBorderRadius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: kFilterItemBorderRadius,
              borderSide: BorderSide(color: theme.colorScheme.secondary, width: 1.5),
            ),
          ),
        );
      },
    );
  }

  // ✅ 3. 全新的 Dropdown 构建方法
  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: kFilterItemHeight,
        child: DropdownButton<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text((item as Enum).name, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: theme.cardColor,
          style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
          icon: Icon(Icons.arrow_drop_down, color: theme.hintColor),
          underline: const SizedBox.shrink(),
          focusColor: Colors.transparent,
        ),
      ),
    );
  }
}