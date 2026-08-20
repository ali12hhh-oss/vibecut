import 'asset_repository.dart';
import '../models/layer_model.dart';

class VideoRepository {
  VideoRepository({AssetRepository? assetRepository}) : _assetRepository = assetRepository ?? AssetRepository();

  final AssetRepository _assetRepository;

  Future<List<String>> getAvailableFilters() async {
    final localFilters = await _assetRepository.getLocalAssets('assets/core/filters/');
    final downloadedFilters = await _assetRepository.getDownloadedAssets('extra_filters');
    return {...localFilters, ...downloadedFilters}.toList()..sort();
  }

  Future<void> saveProject(List<LayerModel> layers) async {
    if (layers.isEmpty) {
      throw StateError('Cannot save an empty project.');
    }
    // Project persistence is intentionally handled by the future storage layer.
  }
}
