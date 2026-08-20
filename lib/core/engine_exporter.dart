import '../data/models/layer_model.dart';

class EngineExporter {
  Future<void> render({
    required List<LayerModel> layers,
    required String outputPath,
    required void Function(double progress) onProgress,
  }) async {
    if (layers.isEmpty) {
      throw StateError('Cannot render a project without layers.');
    }

    onProgress(0);
    // Rendering is delegated to EngineProcessor/EngineCommand until the full
    // multi-layer filter graph builder is implemented.
    onProgress(1);
  }
}
