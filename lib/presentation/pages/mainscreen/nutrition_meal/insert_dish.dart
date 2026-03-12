import 'package:doctor_care/core/database_food/food_database_helper.dart';
import 'package:doctor_care/core/pages/app_color.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/pages/custom_button.dart';
import 'package:doctor_care/domain/entities/food_item.dart';
import 'package:doctor_care/domain/entities/food_nutrition.dart';
import 'package:doctor_care/domain/entities/meal_analysis.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_bloc.dart';
import 'package:doctor_care/presentation/bloc/meal_analysis/meal_analysis_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class InsertDish extends StatefulWidget {
  const InsertDish({super.key});

  @override
  State<InsertDish> createState() => _InsertDishState();
}

class _InsertDishState extends State<InsertDish> {
  final _dishNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final List<FoodItem> _foodItems = [];
  List<FoodNutrition> _searchResults = [];
  bool _isSearching = false;

  double get _totalCalories =>
      _foodItems.fold(0.0, (sum, item) => sum + item.calories);
  double get _totalProtein =>
      _foodItems.fold(0.0, (sum, item) => sum + item.protein);
  double get _totalCarbs =>
      _foodItems.fold(0.0, (sum, item) => sum + item.carbs);
  double get _totalFat =>
      _foodItems.fold(0.0, (sum, item) => sum + item.fat);

  @override
  void dispose() {
    _dishNameController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await FoodDatabaseHelper.instance.searchFoods(query.trim());
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _addFoodItem(FoodNutrition food) {
    _showPortionDialog(food);
  }

  void _showPortionDialog(FoodNutrition food) {
    final portionController = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(food.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(food.nameEn,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const Gap(4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniNutritionInfo("Calo", "${food.caloriesPer100g}", "kcal"),
                  _miniNutritionInfo("Protein", "${food.protein}", "g"),
                  _miniNutritionInfo("Carbs", "${food.carbs}", "g"),
                  _miniNutritionInfo("Fat", "${food.fat}", "g"),
                ],
              ),
            ),
            const Gap(6),
            Text("Trên 100g", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            const Gap(16),
            TextField(
              controller: portionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Khối lượng (gram)",
                hintText: "Nhập khối lượng",
                suffixText: "g",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Hủy", style: TextStyle(color: Colors.grey.shade600)),
          ),
          FilledButton(
            onPressed: () {
              final grams =
                  double.tryParse(portionController.text.trim()) ?? 100;
              final item = FoodItem(
                foodName: food.name,
                foodNameEn: food.nameEn,
                portionGrams: grams,
                calories: food.calculateCalories(grams),
                glycemicIndex: food.glycemicIndex,
                protein: food.calculateProtein(grams),
                carbs: food.calculateCarbs(grams),
                fat: food.calculateFat(grams),
                fiber: food.calculateFiber(grams),
                category: food.category,
              );
              setState(() {
                _foodItems.add(item);
                _searchController.clear();
                _searchResults = [];
              });
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  Widget _miniNutritionInfo(String label, String value, String unit) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text("$label ($unit)",
            style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
      ],
    );
  }

  void _saveMeal() {
    if (_foodItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng thêm ít nhất 1 thực phẩm")),
      );
      return;
    }

    final meal = MealAnalysis(
      timestamp: DateTime.now(),
      imagePath: '',
      dishName: _dishNameController.text.trim().isNotEmpty
          ? _dishNameController.text.trim()
          : "Bữa ăn",
      foodItems: _foodItems,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    context.read<MealAnalysisBloc>().add(SaveMealAnalysisEvent(meal));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đã lưu bữa ăn thành công! 🎉"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomStackAppBar(
        onBack: () => Navigator.pop(context),
        title: "Thêm mới món ăn",
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Tên món ăn ---
                  _buildSectionTitle("Tên món ăn"),
                  const Gap(8),
                  TextField(
                    controller: _dishNameController,
                    decoration: InputDecoration(
                      hintText: "VD: Phở Bò, Cơm Tấm...",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      prefixIcon: const Icon(Icons.restaurant_rounded,
                          color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),

                  const Gap(24),

                  // --- Tìm kiếm thực phẩm ---
                  _buildSectionTitle("Thêm thực phẩm"),
                  const Gap(8),
                  TextField(
                    controller: _searchController,
                    onChanged: _searchFood,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm thực phẩm...",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: Colors.blue),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),

                  // --- Kết quả tìm kiếm ---
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                          child: CircularProgressIndicator(color: Colors.blue)),
                    ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final food = _searchResults[index];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.fastfood_rounded,
                                  color: Colors.blue.shade400, size: 20),
                            ),
                            title: Text(food.name,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              "${food.caloriesPer100g} kcal/100g · ${food.category}",
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                            ),
                            trailing: Icon(Icons.add_circle_rounded,
                                color: Colors.blue.shade400),
                            onTap: () => _addFoodItem(food),
                          );
                        },
                      ),
                    ),

                  const Gap(24),

                  // --- Danh sách thực phẩm đã thêm ---
                  if (_foodItems.isNotEmpty) ...[
                    Row(
                      children: [
                        _buildSectionTitle(
                            "Thực phẩm (${_foodItems.length})"),
                        const Spacer(),
                        Text(
                          "${_totalCalories.toStringAsFixed(0)} kcal",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    ...List.generate(
                        _foodItems.length, (i) => _buildFoodItemCard(i)),

                    const Gap(16),

                    // --- Tổng kết dinh dưỡng ---
                    _buildNutritionSummary(),
                  ],

                  const Gap(24),

                  // --- Ghi chú ---
                  _buildSectionTitle("Ghi chú"),
                  const Gap(8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Ghi chú về bữa ăn (tùy chọn)...",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const Gap(24),
                  CustomButton(
                    expanded: true,
                    text: "Lưu", 
                    onPressed: _saveMeal),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColor.textPrimary(context),
      ),
    );
  }

  Widget _buildFoodItemCard(int index) {
    final item = _foodItems[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lunch_dining_rounded,
                color: Colors.orange.shade400, size: 22),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.foodName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary(context),
                  ),
                ),
                const Gap(2),
                Text(
                  "${item.portionGrams.toStringAsFixed(0)}g · ${item.calories.toStringAsFixed(0)} kcal",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    _buildMacroTag(
                        "P ${item.protein.toStringAsFixed(1)}g", Colors.blue),
                    const Gap(4),
                    _buildMacroTag(
                        "C ${item.carbs.toStringAsFixed(1)}g", Colors.amber.shade700),
                    const Gap(4),
                    _buildMacroTag(
                        "F ${item.fat.toStringAsFixed(1)}g", Colors.red),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: Colors.red.shade300, size: 22),
            onPressed: () {
              setState(() => _foodItems.removeAt(index));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNutritionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tổng kết dinh dưỡng",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Gap(12),
          Row(
            children: [
              _buildSummaryItem(
                  "Calo", "${_totalCalories.toStringAsFixed(0)}", "kcal"),
              _buildSummaryItem(
                  "Protein", "${_totalProtein.toStringAsFixed(1)}", "g"),
              _buildSummaryItem(
                  "Carbs", "${_totalCarbs.toStringAsFixed(1)}", "g"),
              _buildSummaryItem(
                  "Chất béo", "${_totalFat.toStringAsFixed(1)}", "g"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "$label ($unit)",
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}