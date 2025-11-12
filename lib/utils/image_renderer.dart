import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:featch_flow/providers/cache_manager_provider.dart';
import 'package:featch_flow/providers/media_loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. 将 ConsumerWidget 转换为 ConsumerStatefulWidget
class ImageRenderer extends ConsumerStatefulWidget {
  final String imageUrl;
  final Alignment alignment;
  final BoxFit fit;

  const ImageRenderer({
    super.key,
    required this.imageUrl,
    this.alignment = Alignment.center,
    this.fit = BoxFit.contain,
  });

  @override
  ConsumerState<ImageRenderer> createState() => _ImageRendererState();
}

class _ImageRendererState extends ConsumerState<ImageRenderer> {
  // 2. 创建一个 Future 变量来持有加载任务
  // 使用 `late final` 确保它只被初始化一次
  late final Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    // 3. 在 initState 中初始化 Future 并发送加载请求
    // 这是整个生命周期中只会执行一次的地方
    _loadingFuture = _loadImage();
  }

  Future<void> _loadImage() async {
    // 检查图片是否已经加载过，如果是，直接完成
    final completer = Completer<void>();

    // 使用 microtask 确保 ref 在此时是可用的
    Future.microtask(() {
      if (!mounted) {
        completer.completeError('Widget unmounted');
        return;
      }

      final loader = ref.read(mediaLoaderProvider.notifier);
      final cacheManager = ref.read(customCacheManagerProvider);
      bool isCancelled = false;

      loader.addRequest(
        MediaLoadRequest(
          imageUrl: widget.imageUrl,
          addedAt: DateTime.now(),
          onLoad: () async {
            try {
              debugPrint(
                '[ImageRenderer] Starting actual image loading for ${widget.imageUrl}',
              );
              await cacheManager.getSingleFile(widget.imageUrl);

              if (!completer.isCompleted && !isCancelled) {
                debugPrint(
                  '[ImageRenderer] Image fully loaded: ${widget.imageUrl}',
                );
                completer.complete();
              }
              // 在这里调用 completeLoad
              loader.completeLoad(widget.imageUrl);
            } catch (error) {
              if (!completer.isCompleted && !isCancelled) {
                debugPrint(
                  '[ImageRenderer] Failed to load image: ${widget.imageUrl}, error: $error',
                );
                completer.completeError(error);
              }
              // 失败时也要调用 completeLoad 来清理状态
              loader.completeLoad(widget.imageUrl);
            }
          },
          onCancel: () {
            isCancelled = true;
            if (!completer.isCompleted) {
              debugPrint(
                '[ImageRenderer] Image load cancelled: ${widget.imageUrl}',
              );
              completer.completeError('Cancelled');
            }
          },
        ),
      );
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyLoaded = ref.watch(
      mediaLoaderProvider.select(
        (state) => state.loadedUrls.contains(widget.imageUrl),
      ),
    );

    if (isAlreadyLoaded) {
      return _buildImage();
    }

    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return _buildImage();
        } else if (snapshot.hasError) {
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 16),
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 24, // 可以根据你的UI调整大小
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.0, // 让线条细一点
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildImage() {
    final cacheManager = ref.read(customCacheManagerProvider);
    return CachedNetworkImage(
      cacheManager: cacheManager,
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      alignment: widget.alignment,
      fadeInDuration: const Duration(milliseconds: 20),
      fadeOutDuration: const Duration(milliseconds: 20),
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 24, // 可以根据你的UI调整大小
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.0, // 让线条细一点
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image, size: 16),
      ),
    );
  }
}
