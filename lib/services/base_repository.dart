// lib/services/base_repository.dart

import 'package:featch_flow/models/unified_post_model.dart';

// Defines a generic return type using Dart 3's Record.
// It clearly represents: returning a list of posts and a token for the next page.
// 定义一个通用的返回类型，使用 Dart 3 的 Record (记录)。
// 它清晰地表示：返回一个帖子列表 和 下一页的凭证。
typedef RepositoryResponse = (List<UnifiedPostModel> posts, Object? nextToken);

abstract class BaseRepository {
  /// A generic method for fetching a list of posts.
  /// [paginationToken] - The token for pagination (can be an int page or a String cursor).
  /// [filters] - A Map containing all the filter conditions.
  /// Returns a Record containing the list of posts and the next pagination token.
  /// 获取帖子列表的通用方法。
  /// [paginationToken] - 用于分页的凭证 (可以是 int 类型的 page，也可以是 String 类型的 cursor)。
  /// [filters] - 一个包含所有筛选条件的 Map。
  /// 返回一个包含帖子列表和下一个分页凭证的 Record。
  Future<RepositoryResponse> getPosts({
    Object? paginationToken,
    Map<String, dynamic>? filters,
  });
}
