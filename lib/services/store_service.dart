import 'package:dio/dio.dart';
import 'package:jeonmattaeng/config/api_config.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'dio_client.dart';

class StoreService {
  static Future<List<Store>> fetchStores() async {
    final response = await DioClient.dio.get(ApiConfig.stores);
    return (response.data as List)
        .map((json) => Store.fromJson(json))
        .toList();
  }
}
