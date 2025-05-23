import 'package:dio/dio.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'dio_client.dart';

class MenuService {
  static Future<List<Menu>> getMenusByStore(String storeId) async {
    final response = await DioClient.dio.get(ApiConfig.menus(storeId));
    return (response.data as List)
        .map((json) => Menu.fromJson(json))
        .toList();
  }

  static Future<void> likeMenu(String id) async {
    await DioClient.dio.post(ApiConfig.likeMenu(id));
  }

  static Future<void> unlikeMenu(String id) async {
    await DioClient.dio.delete(ApiConfig.unlikeMenu(id));
  }
}
