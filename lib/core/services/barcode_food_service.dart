import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:doctor_care/domain/entities/food_nutrition.dart';

/// Kết quả tra cứu mã vạch: thông tin dinh dưỡng + khối lượng thực của sản phẩm
typedef BarcodeResult = ({FoodNutrition food, double servingGrams});

/// Service tra cứu thông tin dinh dưỡng từ mã vạch
/// Sử dụng Open Food Facts API (miễn phí, không cần key)
class BarcodeFoodService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/api/v2/product';

  /// Tra cứu thực phẩm theo mã vạch (EAN-13, UPC-A, ...)
  /// Trả về [BarcodeResult] gồm FoodNutrition (per 100g) + servingGrams (thể tích/khối lượng thực).
  /// Ví dụ: Lavie 350ml → servingGrams = 350.0
  static Future<BarcodeResult?> lookupBarcode(String barcode) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/$barcode.json'
        '?fields=product_name,product_name_vi,product_name_en,nutriments,categories_tags,serving_quantity,serving_size,quantity',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('[Barcode] status=${response.statusCode} barcode=$barcode');
      }

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint('[Barcode] api_status=${json['status']}');
      }

      if (json['status'] != 1) return null;

      final product = json['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

      // Lấy tên sản phẩm: ưu tiên VI → EN (product_name) → product_name_en
      final nameVi = (product['product_name_vi'] as String?)?.trim() ?? '';
      final nameMain = (product['product_name'] as String?)?.trim() ?? '';
      final nameEn = (product['product_name_en'] as String?)?.trim() ?? '';
      final displayName = nameVi.isNotEmpty
          ? nameVi
          : nameMain.isNotEmpty
              ? nameMain
              : nameEn;

      if (kDebugMode) {
        debugPrint('[Barcode] name="$displayName" nameVi="$nameVi" nameMain="$nameMain" nameEn="$nameEn"');
        debugPrint('[Barcode] nutriments keys=${nutriments.keys.where((k) => k.contains('energy') || k.contains('kcal')).toList()}');
      }

      if (displayName.isEmpty) return null;

      double toDouble(String key) {
        final v = nutriments[key];
        if (v == null) return 0.0;
        if (v is num) return v.toDouble();
        return double.tryParse(v.toString()) ?? 0.0;
      }

      // Calories: thử cả 2 key vì API không nhất quán
      final cal = toDouble('energy-kcal_100g');
      final calories = cal > 0 ? cal : toDouble('energy_kcal_100g');

      // Lấy category từ tags (vd: "en:beverages" → "Beverages")
      final rawTags = product['categories_tags'];
      final categoryTags = rawTags is List
          ? rawTags.map((e) => e.toString()).toList()
          : <String>[];
      final category = categoryTags.isNotEmpty
          ? _cleanCategoryTag(categoryTags.first)
          : 'Thực phẩm đóng gói';

      final food = FoodNutrition(
        name: displayName,
        nameEn: nameEn.isNotEmpty ? nameEn : nameMain.isNotEmpty ? nameMain : displayName,
        caloriesPer100g: calories,
        glycemicIndex: 0,
        protein: toDouble('proteins_100g'),
        carbs: toDouble('carbohydrates_100g'),
        fat: toDouble('fat_100g'),
        fiber: toDouble('fiber_100g'),
        category: category,
      );

      final servingGrams = _resolveServingGrams(product, displayName);

      if (kDebugMode) {
        debugPrint('[Barcode] ✅ ${food.name} — ${food.caloriesPer100g} kcal/100g — serving=${servingGrams}g');
      }

      return (food: food, servingGrams: servingGrams);
    } catch (e, st) {
      if (kDebugMode) debugPrint('[Barcode] ❌ Exception: $e\n$st');
      return null;
    }
  }

  /// Xác định khối lượng/thể tích thực của sản phẩm theo thứ tự ưu tiên:
  /// 1. serving_quantity (số trực tiếp từ API)
  /// 2. serving_size (chuỗi, vd: "350 ml")
  /// 3. quantity (tổng thể tích sản phẩm, vd: "350ml", "1L")
  /// 4. Parse từ tên sản phẩm (vd: "Lavie 350ml" → 350)
  /// 5. Mặc định 100g
  static double _resolveServingGrams(
      Map<String, dynamic> product, String productName) {
    // 1. serving_quantity (thường là số gram/ml)
    final qty = product['serving_quantity'];
    if (qty != null) {
      final v = qty is num ? qty.toDouble() : double.tryParse(qty.toString());
      if (v != null && v > 0) return v;
    }

    // 2. serving_size dạng chuỗi: "350 ml", "330ml", "1 can (355 ml)"
    final sizeStr = (product['serving_size'] as String?)?.toLowerCase() ?? '';
    final fromServing = _extractMl(sizeStr);
    if (fromServing != null) return fromServing;

    // 3. quantity tổng (vd: "350ml", "1 L", "24 x 330ml" → lấy số đầu)
    final quantityStr = (product['quantity'] as String?)?.toLowerCase() ?? '';
    final fromQty = _extractMl(quantityStr);
    if (fromQty != null) return fromQty;

    // 4. Parse từ tên sản phẩm: "Lavie 350ml", "Pepsi 500ml"
    final fromName = _extractMl(productName.toLowerCase());
    if (fromName != null) return fromName;

    return 100.0;
  }

  /// Trích xuất số ml/g từ chuỗi, hỗ trợ:
  /// - "350 ml", "350ml", "350 g"
  /// - "1 l" / "1.5 l" → nhân × 1000
  /// - "1 can (355 ml)" → lấy số trong ngoặc
  static double? _extractMl(String s) {
    if (s.isEmpty) return null;

    // Ưu tiên số trong ngoặc: "(355 ml)" → 355
    final inBrackets = RegExp(r'\((\d+(?:\.\d+)?)\s*(?:ml|g|cl)?\)').firstMatch(s);
    if (inBrackets != null) {
      final v = double.tryParse(inBrackets.group(1)!);
      if (v != null && v > 0) return v;
    }

    // Số đi kèm đơn vị lít → × 1000
    final litreMatch = RegExp(r'(\d+(?:\.\d+)?)\s*l\b').firstMatch(s);
    if (litreMatch != null) {
      final v = double.tryParse(litreMatch.group(1)!);
      if (v != null && v > 0) return v * 1000;
    }

    // Số đi kèm ml hoặc g
    final mlMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(?:ml|g|cl)\b').firstMatch(s);
    if (mlMatch != null) {
      final raw = mlMatch.group(0)!;
      final v = double.tryParse(mlMatch.group(1)!);
      if (v != null && v > 0) {
        return raw.contains('cl') ? v * 10 : v; // 33cl → 330ml
      }
    }

    return null;
  }

  /// Chuyển tag dạng "en:beverages" → "Beverages"
  static String _cleanCategoryTag(String tag) {
    final parts = tag.split(':');
    final raw = parts.length > 1 ? parts.last : parts.first;
    return raw
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }
}
