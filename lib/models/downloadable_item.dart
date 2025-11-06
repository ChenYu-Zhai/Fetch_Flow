// lib/models/downloadable_item.dart
import 'civitai_image_model.dart';
import 'rule34_post_model.dart';

// Defines a contract for items that can be downloaded.
// 定义一个可下载项目的契约。
abstract class DownloadableItem {
  // A unique ID that distinguishes the source.
  // 唯一的、可区分来源的 ID。
  String get uniqueId;
  // The URL for downloading the high-resolution image.
  // 用于下载的高清图 URL。
  String get downloadUrl;
  // The URL for displaying a thumbnail in the UI.
  // 用于在 UI 中显示的缩略图 URL。
  String get thumbnailUrl;
  // The filename for saving the file.
  // 用于保存的文件名。
  String get fileName;
  // The original data object, for future use.
  // 原始数据对象，以备后用。
  Object get source;
}

// Adapter for Civitai items.
// Civitai 项目的适配器。
class CivitaiDownloadableItem implements DownloadableItem {
  final CivitaiImageModel _image;
  CivitaiDownloadableItem(this._image);

  @override
  String get uniqueId => 'civitai-${_image.id}'; // Add a prefix to ensure uniqueness.

  @override
  String get downloadUrl => _image.url;

  @override
  String get thumbnailUrl => _image.url;

  @override
  String get fileName => '${_image.id}.png';

  @override
  Object get source => _image;
}

// Adapter for Rule34 items.
// Rule34 项目的适配器。
class Rule34DownloadableItem implements DownloadableItem {
  final Rule34PostModel _post;
  Rule34DownloadableItem(this._post);

  @override
  String get uniqueId => 'rule34-${_post.id}'; // Add a prefix to ensure uniqueness.

  @override
  String get downloadUrl => _post.fileUrl;

  @override
  String get thumbnailUrl => _post.fileUrl; // Rule34 model doesn't have a separate thumbnail URL, so we reuse fileUrl.

  @override
  String get fileName => '${_post.id}.png';

  @override
  Object get source => _post;
}
