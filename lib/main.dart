// lib/main.dart
import 'package:featch_flow/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await windowManager.ensureInitialized();
     WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  debugPrint('[main] App starting...');
  //debugRepaintRainbowEnabled = true;
  final prefs = await SharedPreferences.getInstance();
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize MediaKit for video playback capabilities.
  // 初始化 MediaKit 以支持视频播放功能。
  MediaKit.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        // 直接提供已加载的实例，后续所有 provider 同步可用
        sharedPreferencesProvider.overrideWithValue(AsyncValue.data(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[MyApp] Building...');
    // Watch the state of sharedPreferencesProvider for async initialization.
    // 监听 sharedPreferencesProvider 的状态，用于异步初始化。
    final asyncValue = ref.watch(sharedPreferencesProvider);

    return MaterialApp(
      title: 'featch_flow',
      theme: ThemeData(
        // Overall brightness set to dark.
        // 整体亮度设为深色。
        brightness: Brightness.dark,

        // Primary color palette.
        // 主色板。
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple[400],

        // Accent color (used for FAB, Slider, etc.).
        // 强调色（用于浮动操作按钮、滑块等）。
        colorScheme:
            ColorScheme.fromSwatch(
              primarySwatch: Colors.deepPurple,
              brightness: Brightness.dark,
            ).copyWith(
              secondary: Colors.tealAccent[400], // A bright contrasting color.
            ),

        // Background colors.
        // 背景颜色。
        scaffoldBackgroundColor: const Color(
          0xFF1A1A1A,
        ), // Slightly brighter background.
        canvasColor: const Color(
          0xFF2C2C2C,
        ), // Significantly brighter card color.
        // AppBar theme.
        // AppBar 主题。
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Make AppBar transparent.
          elevation: 0, // Remove shadow for a flatter look.
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: Color.fromRGBO(255, 255, 255, 0.87)),
        ),

        // Bottom navigation bar theme.
        // 底部导航栏主题。
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: Colors.deepPurple[300],
          unselectedItemColor: Colors.grey[600],
        ),

        // Input field theme (will affect our search bar).
        // 输入框主题（将影响搜索框）。
        inputDecorationTheme: InputDecorationTheme(
          // Unify the style of all input fields.
          // 统一所有输入框的样式。
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // No border by default.
          ),
          fillColor: const Color.fromRGBO(
            255,
            255,
            255,
            0.1,
          ), // Default fill color.
          filled: true,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
      // Decide which page to display based on the async state.
      // 根据异步状态决定显示哪个页面。
      home: asyncValue.when(
        // When data (SharedPreferences instance) is successfully loaded, show the main screen.
        // 当数据（SharedPreferences 实例）成功加载后，显示主屏幕。
        data: (_) {
          debugPrint('[MyApp] SharedPreferences loaded, showing MainScreen.');
          return const MainScreen();
        },
        // While loading, show a loading indicator.
        // 在加载时，显示一个加载指示器。
        loading: () {
          debugPrint('[MyApp] Loading SharedPreferences...');
          return const SplashScreen();
        },
        // If loading fails, show an error page.
        // 如果加载失败，显示一个错误页面。
        error: (err, stack) {
          debugPrint('[MyApp] Error loading SharedPreferences: $err');
          return ErrorScreen(error: err);
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class ErrorScreen extends StatelessWidget {
  final Object error;
  const ErrorScreen({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Failed to initialize the app: $error")),
    );
  }
}
