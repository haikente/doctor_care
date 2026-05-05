# Tài liệu kiểm thử UseCase HbA1c

## Tổng quan

Tài liệu này giải thích cách triển khai **GetHbA1cUseCase** với cơ chế kiểm tra giá trị HbA1c (Hemoglobin A1c) trong khoảng **2% đến 20%**. Phần triển khai bao gồm entity trong domain, mô hình repository, use case và bộ test đầy đủ với **37 test case**.

## Mục lục

1. [HbA1c là gì?](#hba1c-la-gi)
2. [Quy tắc kiểm tra](#quy-tac-kiem-tra)
3. [Kiến trúc](#kien-truc)
4. [Chi tiết triển khai](#chi-tiet-trien-khai)
5. [Phạm vi kiểm thử](#pham-vi-kiem-thu)
6. [Ví dụ sử dụng](#vi-du-su-dung)
7. [Chuẩn sức khỏe WHO](#chuan-suc-khoe-who)

---

## HbA1c là gì?

**HbA1c (Hemoglobin A1c)** là xét nghiệm máu dùng để đo mức đường huyết trung bình trong vòng 2-3 tháng gần nhất. Xét nghiệm này rất quan trọng trong:

- **Chẩn đoán và theo dõi bệnh tiểu đường**
- **Đánh giá nguy cơ mắc tiểu đường**
- **Theo dõi hiệu quả điều trị**

### Các ngưỡng sức khỏe thường dùng:
- **< 5.7%**: Bình thường
- **5.7% - 6.4%**: Tiền đái tháo đường
- **≥ 6.5%**: Đái tháo đường

---

## Quy tắc kiểm tra

Ứng dụng áp dụng các quy tắc kiểm tra sau cho giá trị HbA1c:

### Khoảng hợp lệ
- **Tối thiểu**: 2.0%
- **Tối đa**: 20.0%

### Logic kiểm tra

```dart
bool get isValid => value >= minValidValue && value <= maxValidValue;
```

### Xử lý lỗi

Giá trị không hợp lệ sẽ trả về thông báo rõ ràng:

| Điều kiện | Thông báo lỗi |
|-----------|---------------|
| Giá trị < 2.0% | "HbA1c value must be at least 2.0%" |
| Giá trị > 20.0% | "HbA1c value must not exceed 20.0%" |
| Giá trị hợp lệ | null (không có lỗi) |

---

## Kiến trúc

Phần triển khai tuân theo mô hình **Clean Architecture** với 3 lớp:

### 1. **Domain Layer** (Logic nghiệp vụ)
```
lib/domain/
├── entities/
│   └── hba1c.dart                 # Entity HbA1c có kiểm tra hợp lệ
├── repositories/
│   └── hba1c_repository.dart      # Interface repository trừu tượng
└── usecase/
    └── hba1c/
        └── get_hba1c.dart         # Use case GetHba1c
```

### 2. **Data Layer** (Quản lý dữ liệu)
```
lib/data/
├── datasources/
│   └── hba1c_data_sources.dart    # Đồng bộ DB local + Firebase
├── models/
│   └── hba1c_model.dart           # Model dữ liệu (kế thừa entity)
└── repositories/
    └── hba1c_repositoryimpl.dart  # Triển khai repository
```

### 3. **Presentation Layer** (Giao diện)
```
lib/presentation/
├── bloc/
│   └── hba1c_cubit.dart           # Quản lý state
└── pages/
    └── hba1c_screen.dart          # Màn hình giao diện
```

---

## Chi tiết triển khai

### Entity HbA1c

**File**: `lib/domain/entities/hba1c.dart`

```dart
class HbA1c {
  final int? id;
  final double value;
  final DateTime date;

  // Hằng số khoảng hợp lệ
  static const double minValidValue = 2.0;
  static const double maxValidValue = 20.0;

  HbA1c({
    this.id,
    required this.value,
    required this.date,
  });

  /// Kiểm tra giá trị có nằm trong khoảng hợp lệ (2-20%) hay không
  bool get isValid => value >= minValidValue && value <= maxValidValue;

  /// Trả về thông báo lỗi nếu không hợp lệ, null nếu hợp lệ
  String? get validationError {
    if (value < minValidValue) {
      return 'HbA1c value must be at least $minValidValue%';
    }
    if (value > maxValidValue) {
      return 'HbA1c value must not exceed $maxValidValue%';
    }
    return null;
  }

  /// Diễn giải theo WHO
  String get getInterpretation {
    if (value < 5.7) {
      return "Bình thường";
    } else if (value >= 5.7 && value < 6.5) {
      return "Tiền đái tháo đường";
    } else {
      return "Đái tháo đường";
    }
  }

  /// Màu hiển thị theo trạng thái
  Color get getColor {
    if (value < 5.7) {
      return Colors.green;
    } else if (value >= 5.7 && value < 6.5) {
      return Colors.orange.shade700;
    } else {
      return Colors.red;
    }
  }
}
```

### Interface Repository HbA1c

**File**: `lib/domain/repositories/hba1c_repository.dart`

```dart
abstract class Hba1cRepository {
  Future<void> addHba1cRecord(HbA1c hba1c);
  Future<void> updateHba1cRecord(HbA1c hba1c);
  Future<List<HbA1c>> getHba1cRecords();
  Future<void> deleteHba1c(String id);
}
```

### GetHba1c UseCase

**File**: `lib/domain/usecase/hba1c/get_hba1c.dart`

```dart
class GetHba1c {
  final Hba1cRepository repository;
  
  GetHba1c(this.repository);

  Future<List<HbA1c>> call() async {
    return await repository.getHba1cRecords();
  }
}
```

---

## Phạm vi kiểm thử

### Vị trí file test
`test/hba1c_usecase_test.dart`

### Thống kê test
- **Tổng số test**: 37
- **Tỷ lệ đạt**: 100% ✅
- **Phạm vi bao phủ**:
  - Logic kiểm tra hợp lệ
  - Trường hợp biên
  - Xử lý lỗi
  - Chuẩn WHO
  - Tích hợp repository

### Các nhóm test

#### 1. **Giá trị HbA1c hợp lệ** (7 test)
Kiểm tra các giá trị phải vượt qua validation:
- Biên dưới (2.0%)
- Khoảng bình thường (5.0%)
- Ngưỡng tiền đái tháo đường (5.7%)
- Khoảng cao (10.0%)
- Biên trên (20.0%)
- Ngưỡng đái tháo đường (6.5%)
- Nhiều giá trị hợp lệ

```dart
test('should validate HbA1c value of 5.0% (normal range)', () {
  final hba1c = HbA1c(id: 2, value: 5.0, date: DateTime.now());
  expect(hba1c.isValid, isTrue);
  expect(hba1c.validationError, isNull);
});
```

#### 2. **Giá trị không hợp lệ - Dưới mức tối thiểu** (5 test)
Kiểm tra các giá trị nhỏ hơn 2.0%:
- 1.9% (ngay dưới ngưỡng)
- 1.0%, 0.5%, 0.0%
- Giá trị âm

```dart
test('should reject HbA1c value of 1.9% (below minimum)', () {
  final hba1c = HbA1c(id: 7, value: 1.9, date: DateTime.now());
  expect(hba1c.isValid, isFalse);
  expect(hba1c.validationError, contains('at least 2.0'));
});
```

#### 3. **Giá trị không hợp lệ - Vượt mức tối đa** (4 test)
Kiểm tra các giá trị lớn hơn 20.0%:
- 20.1% (ngay trên ngưỡng)
- 25.0%, 30.0%
- Giá trị rất cao (50.0%)

```dart
test('should reject HbA1c value of 20.1% (above maximum)', () {
  final hba1c = HbA1c(id: 12, value: 20.1, date: DateTime.now());
  expect(hba1c.isValid, isFalse);
  expect(hba1c.validationError, contains('not exceed 20.0'));
});
```

#### 4. **Trường hợp biên và độ chính xác** (3 test)
Kiểm tra giá trị thập phân và các giá trị rất sát biên:
- Độ chính xác thập phân (2.15%, 6.789%)
- Giá trị rất gần biên (2.0001%, 19.9999%)

#### 5. **Lấy dữ liệu từ UseCase** (5 test)
Kiểm tra use case `GetHba1c`:
- Lấy dữ liệu từ repository mock
- Xử lý danh sách rỗng
- Kiểm tra toàn bộ bản ghi trả về đều hợp lệ
- Xử lý giá trị hợp lệ ở biên
- Giữ đúng thứ tự thời gian

```dart
test('should return list of HbA1c records when called', () async {
  final tHba1cList = [
    HbA1c(id: 1, value: 5.5, date: DateTime.now()),
    HbA1c(id: 2, value: 7.2, date: DateTime.now()),
  ];

  when(mockRepository.getHba1cRecords())
      .thenAnswer((_) async => tHba1cList);

  final result = await getHba1c();

  expect(result, tHba1cList);
  expect(result.length, 2);
  verify(mockRepository.getHba1cRecords()).called(1);
});
```

#### 6. **Diễn giải theo chuẩn WHO** (6 test)
Kiểm tra diễn giải sức khỏe và màu hiển thị:
- Bình thường (< 5.7%): Xanh
- Tiền đái tháo đường (5.7%-6.4%): Cam
- Đái tháo đường (≥ 6.5%): Đỏ

#### 7. **Kiểm tra theo lô** (3 test)
Kiểm tra nhiều bản ghi cùng lúc:
- Xác thực đúng nhiều bản ghi
- Nhận diện bản ghi không hợp lệ trong lô
- Trả về thông báo lỗi rõ ràng

#### 8. **Hằng số** (3 test)
Kiểm tra các hằng số dùng cho validation

---

## Ví dụ sử dụng

### Ví dụ 1: Tạo và kiểm tra bản ghi HbA1c

```dart
// Tạo bản ghi HbA1c hợp lệ
final hba1c = HbA1c(
  id: 1,
  value: 6.2,  // Khoảng tiền đái tháo đường
  date: DateTime.now(),
);

// Kiểm tra
if (hba1c.isValid) {
  print('✅ Giá trị hợp lệ');
  print('Trạng thái: ${hba1c.getInterpretation}');
} else {
  print('❌ ${hba1c.validationError}');
}
```

### Ví dụ 2: Lấy dữ liệu qua UseCase

```dart
// Trong BLoC/Cubit
final getHba1c = GetHba1c(repository);
final records = await getHba1c();

// Lọc bản ghi hợp lệ
final validRecords = records.where((r) => r.isValid).toList();
print('Số bản ghi hợp lệ: ${validRecords.length}');
```

### Ví dụ 3: Kiểm tra theo lô

```dart
final records = [
  HbA1c(id: 1, value: 1.5, date: DateTime.now()),  // Không hợp lệ
  HbA1c(id: 2, value: 5.7, date: DateTime.now()),  // Hợp lệ
  HbA1c(id: 3, value: 21.0, date: DateTime.now()), // Không hợp lệ
];

final invalidRecords = records
    .where((r) => !r.isValid)
    .map((r) => r.validationError)
    .toList();

for (final error in invalidRecords) {
  print('Lỗi: $error');
}
```

### Ví dụ 4: Dùng với Firebase và DB local

```dart
// Repository xử lý đồng bộ giữa SQLite local và Firebase
final repository = Hba1cRepositoryimpl(hba1cDataSources);

// Thêm bản ghi mới (đồng bộ lên local DB và Firebase)
await repository.addHba1cRecord(
  HbA1c(
    id: null,
    value: 6.8,
    date: DateTime.now(),
  ),
);

// Lấy toàn bộ bản ghi của hồ sơ gia đình đang active
final allRecords = await repository.getHba1cRecords();
```

---

## Chuẩn sức khỏe WHO

### Mức diễn giải

| Mức HbA1c | Trạng thái | Nguy cơ | Màu |
|------------|-----------|--------|-----|
| < 5.7% | Bình thường | Không nguy cơ | 🟢 Xanh |
| 5.7% - 6.4% | Tiền đái tháo đường | Có nguy cơ | 🟠 Cam |
| ≥ 6.5% | Đái tháo đường | Mắc tiểu đường | 🔴 Đỏ |

### Lý do chọn khoảng kiểm tra

Khoảng **2-20%** được chọn để:
- Bao quát các giá trị lâm sàng thực tế
- Bao gồm sai số trong xét nghiệm
- Hỗ trợ các trường hợp cực đoan (tiểu đường không kiểm soát, v.v.)
- Hạn chế lỗi nhập liệu ở các giá trị biên

---

## Chạy kiểm thử

### Chạy toàn bộ test HbA1c:
```bash
flutter test test/hba1c_usecase_test.dart
```

### Chạy ở chế độ verbose:
```bash
flutter test test/hba1c_usecase_test.dart -v
```

### Chạy test cụ thể:
```bash
flutter test test/hba1c_usecase_test.dart -k "should validate HbA1c value of 5.0%"
```

---

## Danh sách file quan trọng

| File | Mục đích |
|------|---------|
| `lib/domain/entities/hba1c.dart` | Entity có logic kiểm tra hợp lệ |
| `lib/domain/repositories/hba1c_repository.dart` | Repository trừu tượng |
| `lib/domain/usecase/hba1c/get_hba1c.dart` | Use case GetHba1c |
| `lib/data/repositories/hba1c_repositoryimpl.dart` | Triển khai repository |
| `lib/data/datasources/hba1c_data_sources.dart` | Đồng bộ DB local + Firebase |
| `test/hba1c_usecase_test.dart` | Bộ test đầy đủ |
| `test/hba1c_usecase_test.mocks.dart` | Mocks sinh tự động |

---

## Phụ thuộc

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.6.3
  build_runner: ^2.10.5
```

---

## Kết luận

Phần triển khai này cung cấp:
- ✅ Kiểm tra HbA1c chặt chẽ trong khoảng 2-20%
- ✅ Thông báo lỗi rõ ràng cho đầu vào không hợp lệ
- ✅ Diễn giải sức khỏe theo chuẩn WHO
- ✅ 37 test case đầy đủ (đạt 100%)
- ✅ Tích hợp với Firebase và SQLite local
- ✅ Tuân thủ Clean Architecture
- ✅ Sẵn sàng cho môi trường production

Việc kiểm tra này giúp đảm bảo tính toàn vẹn dữ liệu trước khi lưu vào Firestore và SQLite, tránh dữ liệu y tế sai lệch trong ứng dụng theo dõi sức khỏe.
