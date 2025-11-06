// lib/config/network_config.dart

// User-Agent string to mimic a common browser.
// 伪装成主流浏览器的 User-Agent 字符串。
const String browserUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36';

// Global HTTP headers for native platforms.
// 原生平台全局共享的 HTTP 请求头。
const Map<String, String> nativeHttpHeaders = {
  'User-Agent': browserUserAgent,
};
