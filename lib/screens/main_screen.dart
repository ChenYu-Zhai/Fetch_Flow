// lib/screens/main_screen.dart

import 'package:featch_flow/providers/unified_gallery_provider.dart';
import 'package:featch_flow/screens/settings_screen.dart';
import 'package:featch_flow/screens/unified_gallery_screen.dart';
import 'package:featch_flow/widgets/custom_title_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:featch_flow/models/civitai_filters.dart';
import 'package:featch_flow/widgets/civitai_filter_panel.dart';

const List<String> enabledSources = ['civitai', 'rule34'];

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  void _applyCivitaiFilter(CivitaiFilterState newFilters) {
    setState(() {
      _civitaiFilters = newFilters;
    });
    debugPrint(
      '[MainScreen] Applying Civitai filters: ${newFilters.toApiParams()}',
    );
    ref
        .read(unifiedGalleryProvider('civitai').notifier)
        .applyFiltersAndRefresh(newFilters.toApiParams());
  }

  CivitaiFilterState _civitaiFilters = const CivitaiFilterState();
  final List<Widget> _pages = enabledSources
      .map((sourceId) => UnifiedGalleryScreen(sourceId: sourceId))
      .toList();
  @override
  void initState() {
    super.initState();
    debugPrint('[MainScreen] Initialized.');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
    debugPrint('[MainScreen] Disposed.');
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    debugPrint('[MainScreen] Tab tapped: $index');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentSource = enabledSources[_currentIndex];
        final currentFilters = ref
            .read(unifiedGalleryProvider(currentSource))
            .asData
            ?.value
            .filters;
        final currentQuery = _getCurrentQuery(currentSource, currentFilters);

        if (_searchController.text != currentQuery) {
          _searchController.text = currentQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }
      }
    });
  }

  void _performSearch(String query) {
    final currentSource = enabledSources[_currentIndex];
    debugPrint(
      '[MainScreen] Performing search on source "$currentSource" with query: "$query"',
    );
    final notifier = ref.read(unifiedGalleryProvider(currentSource).notifier);

    Map<String, dynamic> filters = {};
    if (currentSource == 'rule34') {
      filters = {'tags': query};
    } else if (currentSource == 'civitai') {
      filters = {'username': query};
    }

    notifier.applyFiltersAndRefresh(filters);
  }

  void _clearSearch() {
    _searchController.clear();
    final currentSource = enabledSources[_currentIndex];
    debugPrint('[MainScreen] Clearing search on source "$currentSource"');
    ref
        .read(unifiedGalleryProvider(currentSource).notifier)
        .applyFiltersAndRefresh({});
  }

  @override
  Widget build(BuildContext context) {
    final currentSource = enabledSources[_currentIndex];

    return Scaffold(
      body: Column(
        children: [

          const CustomTitleBar(),

          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: _buildAppBarTitle(currentSource),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref
                          .read(unifiedGalleryProvider(currentSource).notifier)
                          .refresh();
                    },
                    tooltip: 'Refresh',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      debugPrint('[MainScreen] Navigating to Settings screen.');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: IndexedStack(index: _currentIndex, children: _pages),

              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                items: enabledSources.map((sourceId) {
                  return BottomNavigationBarItem(
                    icon: Icon(_getSourceIcon(sourceId)),
                    label: sourceId.toUpperCase(),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(String source) {
    switch (source) {
      case 'civitai':
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(source.toUpperCase()),
            ),
            Expanded(
              child: CivitaiFilterPanel(
                currentFilters: _civitaiFilters,
                onFiltersChanged: (newFilters) {
                  _applyCivitaiFilter(newFilters);
                },
              ),
            ),
          ],
        );

      case 'rule34':
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(source.toUpperCase()),
            ),
            const SizedBox(width: 8),
            Expanded(child: _buildSearchField(source)),
          ],
        );

      default:
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(source.toUpperCase()),
        );
    }
  }

  Widget _buildSearchField(String source) {
    bool isSearchable = (source == 'rule34');

    if (!isSearchable) {
      return Text(source.toUpperCase());
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        cursorColor: theme.colorScheme.secondary,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => _performSearch(value),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: theme.hintColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: theme.hintColor),
            onPressed: _clearSearch,
          ),
          hintText: 'Search in $source...',
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  IconData _getSourceIcon(String sourceId) {
    switch (sourceId) {
      case 'civitai':
        return Icons.image;
      case 'rule34':
        return Icons.tag;
      default:
        return Icons.web;
    }
  }

  String _getCurrentQuery(String source, Map<String, dynamic>? filters) {
    if (filters == null) return '';

    if (source == 'rule34') {
      return filters['tags'].toString();
    } else if (source == 'civitai') {
      if (filters.containsKey('username') && filters['username'] is String) {
        return filters['username'];
      }

      if (filters.containsKey('modelId') && filters['modelId'] is int) {
        return filters['modelId'].toString();
      }
    }

    return '';
  }
}

class PostSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;
  final String sourceId;

  PostSearchDelegate(this.ref, this.sourceId);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty) {
        final notifier = ref.read(unifiedGalleryProvider(sourceId).notifier);
        Map<String, dynamic> filters = {};
        if (sourceId == 'rule34') {
          filters = {'tags': query};
        }
        notifier.applyFiltersAndRefresh(filters);
      }
      close(context, query);
    });

    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
        hintStyle: TextStyle(color: Theme.of(context).hintColor),
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
        titleLarge: TextStyle(
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
        ),
      ),
    );
  }
}
