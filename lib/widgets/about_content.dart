import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  static const String name = "Jane Doe";
  static const String title = "Senior Product Designer";
  static const String githubUrl =
      "https://github.com/ChenYu-Zhai"; 
  static const String patreonlUrl =
      "https://patreon.com/hakimi_dev";
  static const String afdianUrl = "https://afdian.com/a/hakimi_dev";
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // 增加垂直方向的内边距
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 2. 姓名与头衔 ---
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 12), // 增加较大的间距
          // --- 3. 链接按钮 ---
          _buildLinkButton(
            context: context,
            icon: EvaIcons.githubOutline,
            text: 'GitHub',
            onPressed: () => _launchUrl(githubUrl),
          ),
          const SizedBox(height: 12),
          _buildLinkButton(
            context: context,
            icon: EvaIcons.link2Outline,
            text: 'Patreon Website',
            onPressed: () => _launchUrl(patreonlUrl),
          ),
          const SizedBox(height: 12),
          _buildLinkButton(
            context: context,
            icon: EvaIcons.link2Outline,
            text: 'Afdian Website',
            onPressed: () => _launchUrl(afdianUrl),
          ),
          // --- 5. 版本号信息 (移到底部) ---
          const SizedBox(height: 48),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  // 辅助方法：构建自定义样式的次要链接按钮
  Widget _buildLinkButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(text),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceVariant.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // 辅助方法：异步构建版本信息
  Widget _buildVersionInfo() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final info = snapshot.data!;
          return Text(
            'Version: ${info.version} (Build ${info.buildNumber})',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          );
        }
        return const SizedBox.shrink(); // 加载中或失败时不显示
      },
    );
  }

  // 辅助方法：启动 URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      // 可以在这里显示一个 SnackBar 提示错误
      print('Could not launch $urlString');
    }
  }
}
