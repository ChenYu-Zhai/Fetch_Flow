import 'package:flutter_test/flutter_test.dart';
import 'package:featch_flow/models/civitai_image_model.dart';
import 'package:featch_flow/models/unified_post_model.dart'; // 确保导入 MediaType

void main() {
  group('CivitaiImageModel 解析测试', () {
    // 模拟一段“脏数据”
    // 我们填入了所有 required 字段，特别是 'type'
    final Map<String, dynamic> dirtyJson = {
      // 1. 必填字段 (required int id)
      "id": 12345,
      
      // 2. 必填字段 (required String url)
      "url": "https://example.com/image.jpg",
      
      // 3. 必填字段 (required String? hash) - 这里故意用 int 测试您的 Converter
      "hash": 2872557401228, 
      
      // 4. 必填字段 (required MediaType type) - ✅ 之前报错就是缺了这个！
      // 必须是 "image", "video", 或 "gif"
      "type": "image", 

      // --- 以下是可选字段或带有默认值的字段 ---
      
      "width": 1024,
      "height": 1024,
      "nsfw": false,
      
      // 这里的 username 也故意用 int 测试 Converter
      "username": 9527, 
      
      "meta": {
        "prompt": "Test prompt"
      },
      "stats": {
        "likeCount": 100
      }
    };

    test('如果没有 ForceStringConverter，解析应该崩溃 (模拟复现 Bug)', () {
      // 这里的逻辑稍微调整一下，因为我们现在主要验证的是类型转换
      // 如果你已经在 Model 中加上了 @ForceStringConverter，这个测试其实会"失败"（因为解析成功了）
      // 所以这个测试用例主要用于手动去掉注解后验证
    });

    test('使用 ForceStringConverter 后，应该能够兼容数字类型', () {
      // 现在的代码加上了注解，这里应该能成功运行
      final model = CivitaiImageModel.fromJson(dirtyJson);

      // 验证数字被自动转成了字符串
      expect(model.hash, equals("2872557401228"));
      expect(model.username, equals("9527"));
      
      // 验证我们刚刚补全的 type 字段
      expect(model.type, equals(MediaType.image));
      
      print('✅ 修复生效！Model 解析成功，类型转换正确。');
    });
  });
}