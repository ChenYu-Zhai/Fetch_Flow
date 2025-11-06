// lib/services/parsing_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Defines a generic parsing function type (typedef).
// It accepts a generic parameter R (the type to return) and a dynamic type of data.
// 定义一个通用的解析函数类型 (typedef)。
// 它接受一个泛型参数 R (要返回的类型) 和一个动态类型的数据。
typedef DataParser<R, T> = R Function(T data);

class ParsingService {
  /// Parses data in a background isolate and returns a strongly typed object.
  ///
  /// [data] - The raw data from the network response (e.g., a JSON string or a decoded Map).
  /// [parser] - A top-level function or static method that knows how to parse the data
  ///            into the desired type R (e.g., List<CivitaiImageModel>).
  ///
  /// Returns a Future<R>, where R is the data model you ultimately want.
  /// 在后台 Isolate 中解析数据并返回强类型对象。
  ///
  /// [data] - 从网络响应中获取的原始数据 (例如，JSON 字符串或已解码的 Map)。
  /// [parser] - 一个顶层函数或静态方法，它知道如何将数据
  ///            解析为你想要的类型 R (例如，List<CivitaiImageModel>)。
  ///
  /// 返回一个 Future<R>，其中 R 是你最终想要的数据模型。
  Future<R> parseDataInBackground<R, T>(T data, DataParser<R, T> parser) async {
    debugPrint('[ParsingService] Starting to parse data in background...');
    final result = await compute(parser, data);
    debugPrint('[ParsingService] Finished parsing data in background.');
    return result;
  }
}

// Create a global Provider for ParsingService.
// 创建 ParsingService 的全局 Provider。
final parsingServiceProvider = Provider((_) => ParsingService());
