import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:doctor_care/core/services/health_context_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:doctor_care/domain/entities/food_item.dart';
import 'package:doctor_care/core/database_food/food_database_helper.dart';

class GeminiAIService {
  static const String _defaultApiKey =
      '';
  late final GenerativeModel _model;

  static const int _requestTimeoutSeconds = 60;

  static const int _maxRetries = 3;

  GeminiAIService({String? apiKey}) {
    final key = apiKey ?? _defaultApiKey;
    _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: key);
  }

  Future<Map<String, dynamic>> analyzeMealImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final healthContext =
          await HealthContextService.buildLatestHealthContext();

      final prompt = _createAnalysisPrompt(healthContext);
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      debugPrint('🔍 [AI] Đang phân tích ảnh bữa ăn...');
      final response = await _generateWithRetry(content);
      final responseText = response.text ?? '';
      debugPrint(
        '✅ [AI] Nhận phản hồi phân tích (${responseText.length} chars)',
      );

      return await _parseAIResponse(responseText);
    } catch (e) {
      debugPrint('❌ [AI] Lỗi phân tích ảnh: $e');
      throw Exception('Failed to analyze meal image: $e');
    }
  }

  /// Gợi ý bữa ăn dựa trên dữ liệu sức khỏe và dinh dưỡng hôm nay
  Future<Map<String, dynamic>> suggestMeal({String? mealType}) async {
    try {
      final healthContext =
          await HealthContextService.buildLatestHealthContext();

      final prompt = _createMealSuggestionPrompt(healthContext, mealType);
      final content = [Content.text(prompt)];

      debugPrint('🍽️ [AI] Đang gợi ý bữa ăn (loại: ${mealType ?? "auto"})...');
      final response = await _generateWithRetry(content);
      final responseText = response.text ?? '';
      debugPrint('✅ [AI] Nhận phản hồi gợi ý (${responseText.length} chars)');

      return _parseMealSuggestionResponse(responseText);
    } catch (e) {
      debugPrint('❌ [AI] Lỗi gợi ý bữa ăn: $e');
      throw Exception('Failed to suggest meal: $e');
    }
  }

  /// Gọi AI với retry logic + timeout
  Future<GenerateContentResponse> _generateWithRetry(
    List<Content> content,
  ) async {
    Exception? lastError;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final response = await _model
            .generateContent(content)
            .timeout(
              Duration(seconds: _requestTimeoutSeconds),
              onTimeout: () => throw TimeoutException(
                'AI request timeout after ${_requestTimeoutSeconds}s',
              ),
            );
        return response;
      } on TimeoutException catch (e) {
        lastError = Exception(e.message);
        debugPrint('⏱️ [AI] Timeout lần $attempt/$_maxRetries');
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('⚠️ [AI] Lỗi lần $attempt/$_maxRetries: $e');
      }

      if (attempt < _maxRetries) {
        final delay = Duration(seconds: 2 * attempt);
        debugPrint('🔄 [AI] Retry sau ${delay.inSeconds}s...');
        await Future.delayed(delay);
      }
    }

    throw lastError ??
        Exception('AI request failed after $_maxRetries attempts');
  }

  /// Tạo prompt phân tích ảnh, nhúng health context nếu có
  String _createAnalysisPrompt(Map<String, dynamic> healthContext) {
    final healthSection = _buildHealthContextSection(healthContext);

    return '''
Đầu tiên, hãy kiểm tra hình ảnh này:
1. Ảnh có phải là hình ảnh thức ăn/bữa ăn/đồ uống không? (Nếu là ảnh phong cảnh, người, đồ vật không phải thức ăn → không hợp lệ)
2. Ảnh có quá mờ, quá tối, hoặc không thể nhận diện nội dung không? (Nếu không thể xác định được đây là món gì → không hợp lệ)

Nếu ảnh KHÔNG hợp lệ, trả về JSON:
{
  "imageValid": false,
  "invalidReason": "Lý do cụ thể tại sao ảnh không hợp lệ (VD: 'Ảnh không phải thức ăn', 'Ảnh quá mờ không thể nhận diện', 'Ảnh quá tối'...)"
}

Nếu ảnh HỢP LỆ (là ảnh thức ăn rõ ràng), hãy phân tích và trả về:
$healthSection
{
  "imageValid": true,
  "dishName": "Tên món ăn tổng quát (ví dụ: Phở Bò, Cơm Tấm...)",
  "healthRecommendations": "Lời khuyên sức khỏe cá nhân hóa dựa trên thông tin sức khỏe của người dùng bên trên (nếu có). Ví dụ: nếu đường huyết cao thì cảnh báo tinh bột, nếu huyết áp cao thì lưu ý muối... Nếu không có thông tin sức khỏe thì đưa ra lời khuyên chung.",
  "foods": [
    {
      "name": "Tên thành phần/nguyên liệu (ví dụ: Bánh phở, Thịt bò, Nước dùng...)",
      "nameEn": "Tên tiếng Anh (để tra cứu database)",
      "portionGrams": khối lượng ước tính (số, đơn vị gram),
      "category": "Danh mục thực phẩm"
    }
  ]
}

Lưu ý:
- Ước tính khối lượng từng thành phần dựa trên kích thước thực tế trong ảnh
- Tên món ăn phải chính xác và phổ biến ở Việt Nam
- Category có thể là: "Ngũ cốc và sản phẩm chế biến", "Rau", "Thịt và sản phẩm", "Cá và hải sản", "Trái cây", "Sữa và sản phẩm chế biến", "Đồ uống", "Khác"
- Chỉ trả về JSON, không thêm giải thích hay text khác
''';
  }

  /// Tạo prompt gợi ý bữa ăn dựa trên toàn bộ dữ liệu sức khỏe
  String _createMealSuggestionPrompt(
    Map<String, dynamic> ctx,
    String? mealType,
  ) {
    final healthSection = _buildFullHealthContextSection(ctx);
    final mealTypeText = mealType ?? 'bữa ăn tiếp theo';

    return '''
Bạn là chuyên gia dinh dưỡng AI. Dựa trên toàn bộ thông tin sức khỏe bên dưới, hãy gợi ý $mealTypeText phù hợp nhất cho người dùng.

$healthSection

Hãy trả lời theo định dạng JSON sau (QUAN TRỌNG: CHỈ trả về JSON, không thêm text khác):
{
  "mealSuggestions": [
    {
      "dishName": "Tên món ăn gợi ý (Việt Nam)",
      "description": "Mô tả ngắn về món ăn",
      "reason": "Lý do gợi ý dựa trên tình trạng sức khỏe",
      "estimatedCalories": số calo ước tính,
      "suitabilityScore": điểm phù hợp từ 1-10,
      "ingredients": ["nguyên liệu 1", "nguyên liệu 2"],
      "nutritionHighlights": {
        "protein": lượng protein ước tính (g),
        "carbs": lượng carbs ước tính (g),
        "fat": lượng chất béo ước tính (g),
        "fiber": lượng chất xơ ước tính (g)
      },
      "warnings": "Lưu ý nếu có (có thể null)",
      "cookingTip": "Mẹo chế biến để phù hợp sức khỏe"
    }
  ],
  "dailySummary": "Tóm tắt tình trạng dinh dưỡng hôm nay và lý do gợi ý",
  "nutritionGaps": "Các chất dinh dưỡng còn thiếu cần bổ sung",
  "waterReminder": "Nhắc nhở uống nước nếu chưa đủ"
}

Yêu cầu:
- Gợi ý 3-5 món ăn phổ biến ở Việt Nam
- Ưu tiên món ăn phù hợp với tình trạng sức khỏe hiện tại
- Nếu đường huyết cao → ưu tiên món GI thấp, ít tinh bột
- Nếu huyết áp cao → ưu tiên món ít muối, nhiều kali
- Nếu cholesterol cao → ưu tiên món ít chất béo bão hòa
- Nếu creatinine cao (chức năng thận) → hạn chế protein
- Tính toán calo/macro còn thiếu trong ngày để gợi ý phù hợp
- Nếu đã ăn nhiều calo → gợi ý bữa nhẹ
- Nếu chưa ăn gì → gợi ý bữa đầy đủ dinh dưỡng
- Chỉ trả về JSON, không thêm text khác
''';
  }

  /// Chuyển health context thành đoạn text nhúng vào prompt (cho phân tích ảnh)
  String _buildHealthContextSection(Map<String, dynamic> ctx) {
    if (ctx.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('\n--- THÔNG TIN SỨC KHỎE NGƯỜI DÙNG ---');

    _writeUserInfo(buffer, ctx);
    _writeBasicHealthMetrics(buffer, ctx);
    _writeExtendedHealthMetrics(buffer, ctx);
    _writeTodayNutrition(buffer, ctx);

    buffer.writeln(
      'Dựa vào thông tin trên, hãy đưa ra lời khuyên dinh dưỡng phù hợp với tình trạng sức khỏe của người dùng.',
    );
    buffer.writeln('--------------------------------------\n');

    return buffer.toString();
  }

  /// Chuyển health context đầy đủ cho gợi ý bữa ăn
  String _buildFullHealthContextSection(Map<String, dynamic> ctx) {
    if (ctx.isEmpty) {
      return '(Không có dữ liệu sức khỏe — hãy gợi ý bữa ăn cân bằng chung)';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== THÔNG TIN SỨC KHỎE TOÀN DIỆN ===\n');

    _writeUserInfo(buffer, ctx);
    _writeBasicHealthMetrics(buffer, ctx);
    _writeExtendedHealthMetrics(buffer, ctx);
    _writeTodayNutrition(buffer, ctx);

    // TDEE
    final tdee = ctx['estimated_tdee'];
    if (tdee != null) {
      buffer.writeln(
        '📊 TDEE ước tính (calo cần/ngày): ${(tdee as double).toStringAsFixed(0)} kcal',
      );
    }

    // Nước uống
    final water = ctx['today_water_ml'] as int?;
    if (water != null && water > 0) {
      buffer.writeln('💧 Nước đã uống hôm nay: ${water}ml');
    }

    buffer.writeln('\n======================================');

    return buffer.toString();
  }

  void _writeUserInfo(StringBuffer buffer, Map<String, dynamic> ctx) {
    final user = ctx['user'] as Map<String, dynamic>?;
    if (user != null) {
      if (user['age'] != null) buffer.writeln('- Tuổi: ${user['age']}');
      if (user['gender'] != null) {
        buffer.writeln('- Giới tính: ${user['gender']}');
      }
      if (user['height'] != null) {
        buffer.writeln('- Chiều cao: ${user['height']} cm');
      }
      if (user['latest_weight'] != null) {
        buffer.writeln('- Cân nặng gần nhất: ${user['latest_weight']} kg');
      } else if (user['weight'] != null) {
        buffer.writeln('- Cân nặng: ${user['weight']} kg');
      }
    }
  }

  void _writeBasicHealthMetrics(StringBuffer buffer, Map<String, dynamic> ctx) {
    final bs = ctx['latest_blood_sugar'] as Map<String, dynamic>?;
    if (bs != null) {
      buffer.writeln(
        '- Đường huyết gần nhất: ${bs['value']} mmol/L (${bs['mealStatus'] ?? ''}) — đo lúc ${bs['recordedAt'] ?? 'không rõ'}',
      );
    }

    final bp = ctx['latest_blood_pressure'] as Map<String, dynamic>?;
    if (bp != null) {
      buffer.writeln(
        '- Huyết áp gần nhất: ${bp['systolic']}/${bp['diastolic']} mmHg — đo lúc ${bp['recordedAt'] ?? 'không rõ'}',
      );
    }

    final hba1c = ctx['latest_hba1c'] as Map<String, dynamic>?;
    if (hba1c != null) {
      buffer.writeln('- HbA1c gần nhất: ${hba1c['value']}%');
    }

    final chol = ctx['latest_cholesterol'] as Map<String, dynamic>?;
    if (chol != null) {
      buffer.writeln(
        '- Cholesterol: LDL=${chol['ldl']}, HDL=${chol['hdl']}, Triglycerides=${chol['triglycerides']}',
      );
    }

    final bmi = ctx['latest_bmi'] as Map<String, dynamic>?;
    if (bmi != null) {
      buffer.writeln('- BMI gần nhất: ${bmi['value']}');
    }
  }

  void _writeExtendedHealthMetrics(
    StringBuffer buffer,
    Map<String, dynamic> ctx,
  ) {
    final spo2hr = ctx['latest_spo2_heartrate'] as Map<String, dynamic>?;
    if (spo2hr != null) {
      buffer.writeln(
        '- SpO2: ${spo2hr['spo2']}%, Nhịp tim: ${spo2hr['heartRate']} bpm',
      );
    }

    final temp = ctx['latest_temperature'] as Map<String, dynamic>?;
    if (temp != null) {
      buffer.writeln('- Nhiệt độ cơ thể: ${temp['value']}°C');
    }

    final sleep = ctx['latest_sleep'] as Map<String, dynamic>?;
    if (sleep != null) {
      final quality = sleep['quality'];
      final qualityText = quality != null
          ? ['', 'Rất kém', 'Kém', 'Trung bình', 'Tốt', 'Rất tốt'][quality
                as int]
          : '';
      buffer.writeln(
        '- Giấc ngủ gần nhất: ${sleep['bedTime']} → ${sleep['wakeTime']} (Chất lượng: $qualityText)',
      );
    }

    final creatinine = ctx['latest_creatinine'] as Map<String, dynamic>?;
    if (creatinine != null) {
      buffer.writeln(
        '- Creatinine (chức năng thận): ${creatinine['value']} mg/dL',
      );
    }

    final steps = ctx['today_steps'] as Map<String, dynamic>?;
    if (steps != null) {
      buffer.writeln(
        '- Bước chân hôm nay: ${steps['steps']} bước, đốt ~${steps['caloriesBurned'] ?? 0} kcal',
      );
    }
  }

  void _writeTodayNutrition(StringBuffer buffer, Map<String, dynamic> ctx) {
    final nutrition = ctx['today_nutrition'] as Map<String, dynamic>?;
    if (nutrition != null) {
      buffer.writeln('\n📋 DINH DƯỠNG ĐÃ NẠP HÔM NAY:');
      buffer.writeln('- Số bữa ăn: ${nutrition['mealsCount']}');
      buffer.writeln(
        '- Calo: ${(nutrition['totalCalories'] as double).toStringAsFixed(0)} kcal',
      );
      buffer.writeln(
        '- Protein: ${(nutrition['totalProtein'] as double).toStringAsFixed(1)}g',
      );
      buffer.writeln(
        '- Carbs: ${(nutrition['totalCarbs'] as double).toStringAsFixed(1)}g',
      );
      buffer.writeln(
        '- Chất béo: ${(nutrition['totalFat'] as double).toStringAsFixed(1)}g',
      );
      buffer.writeln(
        '- Chất xơ: ${(nutrition['totalFiber'] as double).toStringAsFixed(1)}g',
      );
    } else {
      buffer.writeln('\n📋 Chưa ghi nhận bữa ăn nào hôm nay.');
    }
  }

  // 
  Future<Map<String, dynamic>> _parseAIResponse(String responseText) async {
    try {
      final cleanedText = _cleanJsonResponse(responseText);

      final jsonResponse = _parseJson(cleanedText);

      // Kiểm tra tính hợp lệ của ảnh
      final imageValid = jsonResponse['imageValid'] as bool? ?? true;
      if (!imageValid) {
        final invalidReason = jsonResponse['invalidReason'] as String? ??
            'Ảnh không hợp lệ';
        debugPrint('⚠️ [AI] Ảnh không hợp lệ: $invalidReason');
        return {
          'imageValid': false,
          'invalidReason': invalidReason,
        };
      }

      final dishName = jsonResponse['dishName'] as String?;
      final healthRecommendations =
          jsonResponse['healthRecommendations'] as String?;
      final foodsList = jsonResponse['foods'] as List<dynamic>;

      final List<FoodItem> foodItems = [];

      for (var foodData in foodsList) {
        final name = foodData['name'] as String;
        final nameEn = foodData['nameEn'] as String;
        final portionGrams = (foodData['portionGrams'] as num).toDouble();
        final category = foodData['category'] as String;

        final nutritionData = await _findFoodInDatabase(name, nameEn);

        if (nutritionData != null) {
          foodItems.add(
            FoodItem(
              foodName: nutritionData.name,
              foodNameEn: nutritionData.nameEn,
              portionGrams: portionGrams,
              calories: nutritionData.calculateCalories(portionGrams),
              glycemicIndex: nutritionData.glycemicIndex,
              protein: nutritionData.calculateProtein(portionGrams),
              carbs: nutritionData.calculateCarbs(portionGrams),
              fat: nutritionData.calculateFat(portionGrams),
              fiber: nutritionData.calculateFiber(portionGrams),
              category: nutritionData.category,
            ),
          );
        } else {
          debugPrint(
            '⚠️ [AI] Food "$name" không tìm thấy trong DB, dùng fallback',
          );
          final fallback = _getFallbackNutrition(category, portionGrams);
          foodItems.add(
            FoodItem(
              foodName: name,
              foodNameEn: nameEn,
              portionGrams: portionGrams,
              calories: fallback['calories']!,
              glycemicIndex: fallback['gi']!.toInt(),
              protein: fallback['protein']!,
              carbs: fallback['carbs']!,
              fat: fallback['fat']!,
              fiber: fallback['fiber']!,
              category: category,
            ),
          );
        }
      }

      return {
        'imageValid': true,
        'dishName': dishName ?? 'Món ăn chưa đặt tên',
        'healthRecommendations': healthRecommendations,
        'foodItems': foodItems,
      };
    } catch (e) {
      throw Exception('Lỗi phân tích dữ liệu bữa ăn: $e');
    }
  }

  /// Parse response gợi ý bữa ăn
  Map<String, dynamic> _parseMealSuggestionResponse(String responseText) {
    try {
      final cleanedText = _cleanJsonResponse(responseText);
      return _parseJson(cleanedText);
    } catch (e) {
      throw Exception('Lỗi phân tích gợi ý bữa ăn: $e');
    }
  }

  /// Làm sạch response AI để lấy JSON thuần
  String _cleanJsonResponse(String responseText) {
    String cleaned = responseText.trim();

    // Loại bỏ markdown code block
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    // Loại bỏ text trước/sau JSON object
    final jsonStart = cleaned.indexOf('{');
    final jsonEnd = cleaned.lastIndexOf('}');
    if (jsonStart >= 0 && jsonEnd > jsonStart) {
      cleaned = cleaned.substring(jsonStart, jsonEnd + 1);
    }

    return cleaned.trim();
  }

  /// Ước tính dinh dưỡng fallback dựa trên category khi không tìm thấy trong DB
  Map<String, double> _getFallbackNutrition(
    String category,
    double portionGrams,
  ) {
    // Hệ số dinh dưỡng trung bình theo category (tính per 100g)
    final Map<String, Map<String, double>> categoryDefaults = {
      'Ngũ cốc và sản phẩm chế biến': {
        'cal': 3.5,
        'protein': 0.08,
        'carbs': 0.70,
        'fat': 0.02,
        'fiber': 0.03,
        'gi': 70,
      },
      'Thịt và sản phẩm': {
        'cal': 2.5,
        'protein': 0.20,
        'carbs': 0.0,
        'fat': 0.15,
        'fiber': 0.0,
        'gi': 0,
      },
      'Cá và hải sản': {
        'cal': 1.2,
        'protein': 0.20,
        'carbs': 0.0,
        'fat': 0.03,
        'fiber': 0.0,
        'gi': 0,
      },
      'Rau': {
        'cal': 0.3,
        'protein': 0.02,
        'carbs': 0.05,
        'fat': 0.005,
        'fiber': 0.03,
        'gi': 15,
      },
      'Trái cây': {
        'cal': 0.5,
        'protein': 0.01,
        'carbs': 0.12,
        'fat': 0.003,
        'fiber': 0.02,
        'gi': 45,
      },
      'Sữa và sản phẩm chế biến': {
        'cal': 0.6,
        'protein': 0.03,
        'carbs': 0.05,
        'fat': 0.03,
        'fiber': 0.0,
        'gi': 30,
      },
      'Đồ uống': {
        'cal': 0.4,
        'protein': 0.005,
        'carbs': 0.10,
        'fat': 0.0,
        'fiber': 0.0,
        'gi': 60,
      },
    };

    final defaults =
        categoryDefaults[category] ??
        {
          'cal': 1.5,
          'protein': 0.05,
          'carbs': 0.20,
          'fat': 0.03,
          'fiber': 0.02,
          'gi': 50,
        };

    return {
      'calories': portionGrams * defaults['cal']!,
      'protein': portionGrams * defaults['protein']!,
      'carbs': portionGrams * defaults['carbs']!,
      'fat': portionGrams * defaults['fat']!,
      'fiber': portionGrams * defaults['fiber']!,
      'gi': defaults['gi']!,
    };
  }

  Map<String, dynamic> _parseJson(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<dynamic> _findFoodInDatabase(String name, String nameEn) async {
    final dbHelper = FoodDatabaseHelper.instance;
    return await dbHelper.findFood(name, nameEn);
  }
}
