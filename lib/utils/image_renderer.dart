import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:featch_flow/providers/cache_manager_provider.dart';
import 'package:featch_flow/providers/media_loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late final Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _loadImage();
  }

  Future<void> _loadImage() async {
    final completer = Completer<void>();
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
            debugPrint('[ImageRenderer] Loading: ${widget.imageUrl}');
            await cacheManager.getSingleFile(widget.imageUrl);
            if (!completer.isCompleted && !isCancelled) {
              completer.complete();
            }
          },
          onCancel: () {
            isCancelled = true;
            if (!completer.isCompleted) {
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
            color: Colors.transparent,
            child: const Icon(Icons.broken_image, size: 64),
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
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
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.transparent,
        //child: const Icon(Icons.broken_image, size: 64),
      ),
    );
  }
}
