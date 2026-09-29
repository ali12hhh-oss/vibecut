import '../models/layer_model.dart';
import '../../core/engine_resource.dart';

class VideoRepository {
  // ignore: unused_field
  final EngineResource _resourceEngine = EngineResource();

  Future<List<String>> getAvailableFilters() async {
    // جلب الفلاتر من المجلدات المدمجة والمحملة
    return ['sepia', 'bw', 'vivid']; 
  }

  Future<void> saveProject(List<LayerModel> layers) async {
    // حفظ حالة المشروع محلياً
  }
}