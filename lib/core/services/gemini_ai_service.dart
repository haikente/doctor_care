import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:doctor_care/domain/entities/food_item.dart';
import 'package:doctor_care/core/database_food/food_database_generated.dart';

/// Service for analyzing meal images using Gemini AI
class GeminiAIService {
  static const String _defaultApiKey =
      'AIzaSyDr8yAuGLQYiTVJ1-D12B3sEDgWoLh0Kjw';
  late final GenerativeModel _model;

  GeminiAIService({String? apiKey}) {
    final key = apiKey ?? _defaultApiKey;
    _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: key);
  }

  /// Analyze a meal image and return detected food items and dish name
  Future<Map<String, dynamic>> analyzeMealImage(String imagePath) async {
    try {
      // Read image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Create prompt for food analysis
      final prompt = _createAnalysisPrompt();

      // Send request to Gemini
      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      // Parse response and create food items
      return _parseAIResponse(responseText);
    } catch (e) {
      throw Exception('Failed to analyze meal image: $e');
    }
  }

  /// Create detailed prompt for meal analysis
  String _createAnalysisPrompt() {
    return '''
Phân tích hình ảnh bữa ăn này và cung cấp tên món ăn cùng danh sách các thành phần nguyên liệu chi tiết.

Hãy trả lời theo định dạng JSON sau (QUAN TRỌNG: CHỈ trả về JSON, không thêm text khác):
{
  "dishName": "Tên món ăn tổng quát (ví dụ: Phở Bò, Cơm Tấm...)",
  "healthRecommendations": "Lời khuyên sức khỏe ngắn gọn dựa trên thành phần dinh dưỡng của món ăn này (ví dụ: món này nhiều calo nên ăn kèm rau, hoặc tốt cho người tiểu đường...)",
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

  Map<String, dynamic> _parseAIResponse(String responseText) {
    try {
      String cleanedText = responseText.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      }
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      // Parse JSON response
      final jsonResponse = _parseJson(cleanedText);
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

        // Try to find matching food in database
        final nutritionData = _findFoodInDatabase(name, nameEn);

        if (nutritionData != null) {
          // Calculate nutrition for the portion
          final calories = nutritionData.calculateCalories(portionGrams);
          final protein = nutritionData.calculateProtein(portionGrams);
          final carbs = nutritionData.calculateCarbs(portionGrams);
          final fat = nutritionData.calculateFat(portionGrams);
          final fiber = nutritionData.calculateFiber(portionGrams);

          foodItems.add(
            FoodItem(
              foodName: nutritionData.name,
              foodNameEn: nutritionData.nameEn,
              portionGrams: portionGrams,
              calories: calories,
              glycemicIndex: nutritionData.glycemicIndex,
              protein: protein,
              carbs: carbs,
              fat: fat,
              fiber: fiber,
              category: nutritionData.category,
            ),
          );
        } else {
          // Use estimated values if not found in database
          foodItems.add(
            FoodItem(
              foodName: name,
              foodNameEn: nameEn,
              portionGrams: portionGrams,
              calories: portionGrams * 1.5, // Rough estimate
              glycemicIndex: 50, // Medium GI as default
              protein: portionGrams * 0.05,
              carbs: portionGrams * 0.2,
              fat: portionGrams * 0.03,
              fiber: portionGrams * 0.02,
              category: category,
            ),
          );
        }
      }

      return {
        'dishName': dishName ?? "Món ăn chưa đặt tên",
        'healthRecommendations': healthRecommendations,
        'foodItems': foodItems,
      };
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }

  /// Parse JSON using dart:convert
  Map<String, dynamic> _parseJson(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Find food in database by name
  dynamic _findFoodInDatabase(String name, String nameEn) {
    // Search by Vietnamese name first
    for (var entry in FoodDatabaseGenerated.foods.entries) {
      final food = entry.value;
      if (food.name.toLowerCase().contains(name.toLowerCase()) ||
          name.toLowerCase().contains(food.name.toLowerCase())) {
        return food;
      }
    }

    // Search by English name
    for (var entry in FoodDatabaseGenerated.foods.entries) {
      final food = entry.value;
      if (food.nameEn.toLowerCase().contains(nameEn.toLowerCase()) ||
          nameEn.toLowerCase().contains(food.nameEn.toLowerCase())) {
        return food;
      }
    }

    return null;
  }
}
