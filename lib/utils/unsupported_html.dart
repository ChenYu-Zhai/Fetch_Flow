// lib/utils/unsupported_html.dart

// This file provides dummy implementations for HTML-related classes
// when the application is compiled for non-web platforms.
// It prevents compilation errors when `dart.library.html` is not available.
// 此文件为非 Web 平台编译时提供 HTML 相关类的虚拟实现。
// 它避免了在 `dart.library.html` 不可用时的编译错误。

class Blob {
  Blob(List<dynamic> blobParts, [String? type]);
}

class Url {
  static String createObjectURL(dynamic blob) => '';
  static void revokeObjectURL(String url) {}
}

class Document {
  Element createElement(String tag) => Element();
}

class Element {
  String href = '';
  void setAttribute(String name, String value) {}
  void click() {}
}

class HtmlAnchorElement extends Element {}
