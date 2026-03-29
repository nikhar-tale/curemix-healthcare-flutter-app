import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager extends CacheManager {
  static const key = 'curemixImageCache';
  
  // Singleton instance
  static final instance = ImageCacheManager._();

  ImageCacheManager._()
    : super(
        Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 300, // accommodate larger catalog
          repo: JsonCacheInfoRepository(databaseName: key),
          fileService: HttpFileService(),
        ),
      );
}
