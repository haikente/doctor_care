import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHealthCollection {
  final String key;
  final String label;

  const AdminHealthCollection({
    required this.key,
    required this.label,
  });
}

const List<AdminHealthCollection> kAdminHealthCollections = [
  AdminHealthCollection(key: 'step_count', label: 'Dữ liệu Bước chân'),
  AdminHealthCollection(key: 'water_intake', label: 'Lượng nước uống'),
  AdminHealthCollection(key: 'spo2heartrate', label: 'Nhịp tim & SpO2'),
  AdminHealthCollection(key: 'temperature', label: 'Nhiệt độ cơ thể'),
  AdminHealthCollection(key: 'sleep_record', label: 'Giấc ngủ'),
  AdminHealthCollection(key: 'blood_pressure', label: 'Huyết áp'),
  AdminHealthCollection(key: 'blood_sugar', label: 'Đường huyết'),
  AdminHealthCollection(key: 'bmi_weight', label: 'BMI & Cân nặng'),
  AdminHealthCollection(key: 'cholesterol', label: 'Cholesterol'),
  AdminHealthCollection(key: 'creatinine', label: 'Creatinine'),
  AdminHealthCollection(key: 'hba1c', label: 'HbA1c'),
  AdminHealthCollection(key: 'menstrual_cycle', label: 'Chu kỳ kinh nguyệt'),
];

class AdminStats {
  final int totalUsers;
  final int adminCount;
  final int userCount;
  final Map<String, int> healthDocCounts;
  final Map<String, int> last7DaysSteps;

  const AdminStats({
    required this.totalUsers,
    required this.adminCount,
    required this.userCount,
    required this.healthDocCounts,
    required this.last7DaysSteps,
  });

  int docsOf(String collectionKey) => healthDocCounts[collectionKey] ?? 0;

  int get totalHealthDocs =>
      healthDocCounts.values.fold(0, (sum, value) => sum + value);

  // Backward-compatible getters for existing UI usages.
  int get stepCountDocs => docsOf('step_count');

  int get waterIntakeDocs => docsOf('water_intake');

  int get spo2Docs => docsOf('spo2heartrate');

  int get temperatureDocs => docsOf('temperature');
}

class AdminStatsService {
  const AdminStatsService();

  static const _stepCountCollectionKey = 'step_count';

  Future<AdminStats> load() async {
    final fs = FirebaseFirestore.instance;

    // Last 7 days steps sum across all users.
    final last7DaysSteps = <String, int>{};
    final now = DateTime.now();
    final startLocal = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final endExclusiveLocal = startLocal.add(const Duration(days: 7));

    for (int i = 0; i < 7; i++) {
      final d = startLocal.add(Duration(days: i));
      last7DaysSteps[_fmtDayKey(d)] = 0;
    }

    // Prefer fast aggregation queries (count + collectionGroup).
    try {
      final userCounts = await Future.wait<int>([
        _countDocs(fs.collection('users')),
        _countDocs(fs.collection('users').where('role', isEqualTo: 'admin')),
      ]);

      final healthCounts = await Future.wait<int>(
        kAdminHealthCollections
            .map((collection) => _countDocs(fs.collectionGroup(collection.key))),
      );

      final healthDocCounts = <String, int>{
        for (int i = 0; i < kAdminHealthCollections.length; i++)
          kAdminHealthCollections[i].key: healthCounts[i],
      };

      final totalUsers = userCounts[0];
      final adminCount = userCounts[1];
      final userCount = (totalUsers - adminCount) < 0
          ? 0
          : (totalUsers - adminCount);

      try {
        final recentStepsSnap = await fs
            .collectionGroup(_stepCountCollectionKey)
            .where(
              'updatedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startLocal),
            )
            .get();

        for (final doc in recentStepsSnap.docs) {
          final data = doc.data();
          final steps = (data['steps'] is num)
              ? (data['steps'] as num).toInt()
              : int.tryParse('${data['steps']}') ?? 0;

          final dt = _parseStepDateTime(doc.id, data['timestamp']);
          if (dt == null) continue;
          final localDt = dt.toLocal();
          if (localDt.isBefore(startLocal) ||
              !localDt.isBefore(endExclusiveLocal)) {
            continue;
          }

          final dayKey = _fmtDayKey(localDt);
          if (!last7DaysSteps.containsKey(dayKey)) continue;
          last7DaysSteps[dayKey] = (last7DaysSteps[dayKey] ?? 0) + steps;
        }
      } catch (_) {}

      return AdminStats(
        totalUsers: totalUsers,
        adminCount: adminCount,
        userCount: userCount,
        healthDocCounts: healthDocCounts,
        last7DaysSteps: last7DaysSteps,
      );
    } catch (_) {}

    // Users
    final usersSnap = await fs.collection('users').get();
    final totalUsers = usersSnap.docs.length;
    final adminCount = usersSnap.docs
        .where((d) => (d.data())['role'] == 'admin')
        .length;
    final userCount = totalUsers - adminCount;

    final healthDocCounts = <String, int>{
      for (final collection in kAdminHealthCollections) collection.key: 0,
    };

    for (final userDoc in usersSnap.docs) {
      final userRef = fs.collection('users').doc(userDoc.id);
      final snapshots = await Future.wait<QuerySnapshot<Map<String, dynamic>>>(
        kAdminHealthCollections
            .map((collection) => userRef.collection(collection.key).get()),
      );

      QuerySnapshot<Map<String, dynamic>>? stepAllSnap;
      for (int i = 0; i < kAdminHealthCollections.length; i++) {
        final collectionKey = kAdminHealthCollections[i].key;
        final snapshot = snapshots[i];
        healthDocCounts[collectionKey] =
            (healthDocCounts[collectionKey] ?? 0) + snapshot.docs.length;

        if (collectionKey == _stepCountCollectionKey) {
          stepAllSnap = snapshot;
        }
      }

      if (stepAllSnap == null) continue;

      for (final doc in stepAllSnap.docs) {
        final data = doc.data();
        final steps = (data['steps'] is num)
            ? (data['steps'] as num).toInt()
            : int.tryParse('${data['steps']}') ?? 0;

        final dt = _parseStepDateTime(doc.id, data['timestamp']);
        if (dt == null) continue;
        final localDt = dt.toLocal();
        if (localDt.isBefore(startLocal) ||
            !localDt.isBefore(endExclusiveLocal)) {
          continue;
        }

        final dayKey = _fmtDayKey(localDt);
        if (!last7DaysSteps.containsKey(dayKey)) continue;
        last7DaysSteps[dayKey] = (last7DaysSteps[dayKey] ?? 0) + steps;
      }
    }

    return AdminStats(
      totalUsers: totalUsers,
      adminCount: adminCount,
      userCount: userCount,
      healthDocCounts: healthDocCounts,
      last7DaysSteps: last7DaysSteps,
    );
  }

  static Future<int> _countDocs(Query<Map<String, dynamic>> query) async {
    try {
      final aggSnap = await query.count().get();
      return aggSnap.count ?? 0;
    } catch (_) {
      final snap = await query.get();
      return snap.docs.length;
    }
  }

  static DateTime? _parseStepDateTime(String docId, dynamic rawTimestamp) {
    // Prefer timestamp derived from docId for stability.
    final docMillis = _tryParseDocIdMillis(docId);
    if (docMillis != null) {
      return DateTime.fromMillisecondsSinceEpoch(docMillis, isUtc: true);
    }

    if (rawTimestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    }
    if (rawTimestamp is Timestamp) {
      return rawTimestamp.toDate();
    }
    if (rawTimestamp is String) {
      return DateTime.tryParse(rawTimestamp);
    }

    return null;
  }

  static int? _tryParseDocIdMillis(String docId) {
    final idx = docId.lastIndexOf('_t');
    if (idx < 0) return null;
    return int.tryParse(docId.substring(idx + 2));
  }

  static String _fmtDayKey(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }
}
