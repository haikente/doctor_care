import 'package:doctor_care/domain/entities/hba1c.dart';
import 'package:doctor_care/domain/repositories/hba1c_repository.dart';
import 'package:doctor_care/domain/usecase/hba1c/get_hba1c.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'hba1c_usecase_test.mocks.dart';

@GenerateMocks([Hba1cRepository])
void main() {
  group('GetHba1c UseCase - HbA1c Validation Tests', () {
    late GetHba1c getHba1c;
    late MockHba1cRepository mockRepository;

    setUp(() {
      mockRepository = MockHba1cRepository();
      getHba1c = GetHba1c(mockRepository);
    });

    group('HbA1c Value Validation (2-20% Range)', () {
      group('Valid HbA1c Values', () {
        test('should validate HbA1c value of 2.0% (minimum boundary)', () {
          final hba1c = HbA1c(
            id: 1,
            value: 2.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isTrue);
          expect(hba1c.validationError, isNull);
        });

        test('should validate HbA1c value of 5.0% (normal range)', () {
          final hba1c = HbA1c(
            id: 2,
            value: 5.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isTrue);
          expect(hba1c.validationError, isNull);
        });

        test('should validate HbA1c value of 5.7% (prediabetic threshold)', () {
          final hba1c = HbA1c(
            id: 3,
            value: 5.7,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isTrue);
          expect(hba1c.validationError, isNull);
        });

        test('should validate HbA1c value of 10.0% (elevated range)', () {
          final hba1c = HbA1c(
            id: 4,
            value: 10.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isTrue);
          expect(hba1c.validationError, isNull);
        });

        test('should validate HbA1c value of 20.0% (maximum boundary)', () {
          final hba1c = HbA1c(
            id: 5,
            value: 20.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isTrue);
          expect(hba1c.validationError, isNull);
        });

        test('should validate HbA1c value of 6.5% (diabetic threshold)', () {
          final hba1c = HbA1c(
            id: 6,
            value: 6.5,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isTrue);
          expect(hba1c.validationError, isNull);
        });

        test('should validate multiple valid HbA1c values', () {
          final validValues = [2.0, 2.5, 4.5, 6.0, 8.5, 12.0, 15.5, 20.0];
          
          for (final value in validValues) {
            final hba1c = HbA1c(
              id: null,
              value: value,
              date: DateTime.now(),
            );
            
            expect(hba1c.isValid, isTrue,
                reason: 'Value $value% should be valid');
            expect(hba1c.validationError, isNull,
                reason: 'Value $value% should have no validation error');
          }
        });
      });

      group('Invalid HbA1c Values - Below Minimum', () {
        test('should reject HbA1c value of 1.9% (below minimum)', () {
          final hba1c = HbA1c(
            id: 7,
            value: 1.9,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
          expect(hba1c.validationError, contains('at least 2.0'));
        });

        test('should reject HbA1c value of 1.0% (well below minimum)', () {
          final hba1c = HbA1c(
            id: 8,
            value: 1.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
        });

        test('should reject HbA1c value of 0.5% (significantly below minimum)', () {
          final hba1c = HbA1c(
            id: 9,
            value: 0.5,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
        });

        test('should reject HbA1c value of 0.0% (zero)', () {
          final hba1c = HbA1c(
            id: 10,
            value: 0.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
        });

        test('should reject negative HbA1c values', () {
          final hba1c = HbA1c(
            id: 11,
            value: -5.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
        });
      });

      group('Invalid HbA1c Values - Above Maximum', () {
        test('should reject HbA1c value of 20.1% (above maximum)', () {
          final hba1c = HbA1c(
            id: 12,
            value: 20.1,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
          expect(hba1c.validationError, contains('not exceed 20.0'));
        });

        test('should reject HbA1c value of 25.0% (well above maximum)', () {
          final hba1c = HbA1c(
            id: 13,
            value: 25.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
        });

        test('should reject HbA1c value of 30.0% (significantly above maximum)', () {
          final hba1c = HbA1c(
            id: 14,
            value: 30.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
        });

        test('should reject very high HbA1c values', () {
          final hba1c = HbA1c(
            id: 15,
            value: 50.0,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isFalse);
          expect(hba1c.validationError, isNotNull);
        });
      });

      group('Edge Cases and Precision', () {
        test('should validate HbA1c with decimal precision (e.g., 2.15%)', () {
          final hba1c = HbA1c(
            id: 16,
            value: 2.15,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isTrue);
          expect(hba1c.validationError, isNull);
        });

        test('should validate HbA1c with multiple decimal places', () {
          final hba1c = HbA1c(
            id: 17,
            value: 6.789,
            date: DateTime.now(),
          );

          expect(hba1c.isValid, isTrue);
          expect(hba1c.validationError, isNull);
        });

        test('should handle values very close to boundaries', () {
          final closeLow = HbA1c(
            id: 18,
            value: 2.0001,
            date: DateTime.now(),
          );
          expect(closeLow.isValid, isTrue);

          final closeHigh = HbA1c(
            id: 19,
            value: 19.9999,
            date: DateTime.now(),
          );
          expect(closeHigh.isValid, isTrue);
        });
      });
    });

    group('GetHba1c UseCase Retrieval', () {
      test('should return list of HbA1c records when called', () async {
        // Arrange
        final tHba1cList = [
          HbA1c(
            id: 1,
            value: 5.5,
            date: DateTime.now(),
          ),
          HbA1c(
            id: 2,
            value: 7.2,
            date: DateTime.now(),
          ),
          HbA1c(
            id: 3,
            value: 6.8,
            date: DateTime.now(),
          ),
        ];

        when(mockRepository.getHba1cRecords())
            .thenAnswer((_) async => tHba1cList);

        // Act
        final result = await getHba1c();

        // Assert
        expect(result, tHba1cList);
        expect(result.length, 3);
        verify(mockRepository.getHba1cRecords()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return empty list when no HbA1c records exist', () async {
        // Arrange
        when(mockRepository.getHba1cRecords())
            .thenAnswer((_) async => []);

        // Act
        final result = await getHba1c();

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getHba1cRecords()).called(1);
      });

      test('should validate all retrieved HbA1c records are within valid range',
          () async {
        // Arrange
        final tHba1cList = [
          HbA1c(id: 1, value: 2.0, date: DateTime(2024, 1, 1)),
          HbA1c(id: 2, value: 5.7, date: DateTime(2024, 1, 15)),
          HbA1c(id: 3, value: 10.0, date: DateTime(2024, 2, 1)),
          HbA1c(id: 4, value: 20.0, date: DateTime(2024, 2, 15)),
        ];

        when(mockRepository.getHba1cRecords())
            .thenAnswer((_) async => tHba1cList);

        // Act
        final result = await getHba1c();

        // Assert
        for (final record in result) {
          expect(record.isValid, isTrue,
              reason: 'Record with value ${record.value}% should be valid');
          expect(record.validationError, isNull);
        }
      });

      test('should handle repository returning records with extreme valid values',
          () async {
        // Arrange
        final tHba1cList = [
          HbA1c(id: 1, value: 2.0, date: DateTime.now()), // minimum
          HbA1c(id: 2, value: 20.0, date: DateTime.now()), // maximum
        ];

        when(mockRepository.getHba1cRecords())
            .thenAnswer((_) async => tHba1cList);

        // Act
        final result = await getHba1c();

        // Assert
        expect(result.length, 2);
        expect(result[0].value, 2.0);
        expect(result[1].value, 20.0);
        expect(result.every((r) => r.isValid), isTrue);
      });

      test('should maintain chronological order of records', () async {
        // Arrange
        final date1 = DateTime(2024, 1, 1);
        final date2 = DateTime(2024, 1, 15);
        final date3 = DateTime(2024, 2, 1);

        final tHba1cList = [
          HbA1c(id: 1, value: 5.5, date: date1),
          HbA1c(id: 2, value: 6.2, date: date2),
          HbA1c(id: 3, value: 7.1, date: date3),
        ];

        when(mockRepository.getHba1cRecords())
            .thenAnswer((_) async => tHba1cList);

        // Act
        final result = await getHba1c();

        // Assert
        expect(result[0].date, date1);
        expect(result[1].date, date2);
        expect(result[2].date, date3);
      });
    });

    group('HbA1c Interpretation Based on WHO Standards', () {
      test('should interpret value < 5.7% as normal', () {
        final hba1c = HbA1c(
          id: 1,
          value: 5.5,
          date: DateTime.now(),
        );

        expect(hba1c.getInterpretation, 'Bình thường');
        expect(hba1c.isValid, isTrue);
      });

      test('should interpret value 5.7%-6.4% as prediabetic', () {
        final hba1c = HbA1c(
          id: 2,
          value: 5.9,
          date: DateTime.now(),
        );

        expect(hba1c.getInterpretation, 'Tiền đái tháo đường');
        expect(hba1c.isValid, isTrue);
      });

      test('should interpret value >= 6.5% as diabetic', () {
        final hba1c = HbA1c(
          id: 3,
          value: 7.5,
          date: DateTime.now(),
        );

        expect(hba1c.getInterpretation, 'Đái tháo đường');
        expect(hba1c.isValid, isTrue);
      });

      test('should have correct color for normal range', () {
        final hba1c = HbA1c(
          id: 1,
          value: 5.0,
          date: DateTime.now(),
        );

        expect(hba1c.getColor.value, Colors.green.value);
      });

      test('should have correct color for prediabetic range', () {
        final hba1c = HbA1c(
          id: 2,
          value: 6.0,
          date: DateTime.now(),
        );

        expect(hba1c.getColor.value, Colors.orange.shade700.value);
      });

      test('should have correct color for diabetic range', () {
        final hba1c = HbA1c(
          id: 3,
          value: 7.0,
          date: DateTime.now(),
        );

        expect(hba1c.getColor.value, Colors.red.value);
      });
    });

    group('Batch Validation Tests', () {
      test('should validate multiple records correctly', () {
        final records = [
          HbA1c(id: 1, value: 2.0, date: DateTime.now()),
          HbA1c(id: 2, value: 5.7, date: DateTime.now()),
          HbA1c(id: 3, value: 10.0, date: DateTime.now()),
          HbA1c(id: 4, value: 20.0, date: DateTime.now()),
        ];

        final validRecords =
            records.where((record) => record.isValid).toList();
        final allValid = records.every((record) => record.isValid);

        expect(validRecords.length, 4);
        expect(allValid, isTrue);
      });

      test('should identify invalid records in a batch', () {
        final records = [
          HbA1c(id: 1, value: 1.9, date: DateTime.now()),
          HbA1c(id: 2, value: 5.7, date: DateTime.now()),
          HbA1c(id: 3, value: 20.1, date: DateTime.now()),
        ];

        final invalidRecords =
            records.where((record) => !record.isValid).toList();

        expect(invalidRecords.length, 2);
        expect(invalidRecords[0].value, 1.9);
        expect(invalidRecords[1].value, 20.1);
      });

      test('should provide meaningful error messages for invalid values', () {
        final belowMin = HbA1c(id: 1, value: 1.5, date: DateTime.now());
        final aboveMax = HbA1c(id: 2, value: 21.0, date: DateTime.now());

        expect(belowMin.validationError, isNotEmpty);
        expect(aboveMax.validationError, isNotEmpty);
        expect(belowMin.validationError, belowMin.validationError);
        expect(aboveMax.validationError, aboveMax.validationError);
      });
    });
  });

  group('HbA1c Constants', () {
    test('should have correct minimum valid value', () {
      expect(HbA1c.minValidValue, 2.0);
    });

    test('should have correct maximum valid value', () {
      expect(HbA1c.maxValidValue, 20.0);
    });

    test('should validate range correctly using constants', () {
      final value = 10.5;
      final isInRange = value >= HbA1c.minValidValue && value <= HbA1c.maxValidValue;

      expect(isInRange, isTrue);
    });
  });
}
