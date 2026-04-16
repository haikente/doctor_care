import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStats {
  final int totalUsers;
  final int adminCount;
  final int userCount;
  final int stepCountDocs;
  final int waterIntakeDocs;
  final int spo2Docs;
  final int temperatureDocs;
  final Map<String, int> last7DaysSteps;

  const AdminStats({
    required this.totalUsers,
    required this.adminCount,
    required this.userCount,
    required this.stepCountDocs,
    required this.waterIntakeDocs,
    required this.spo2Docs,
    required this.temperatureDocs,
    required this.last7DaysSteps,
  });
}

class AdminStatsService {
  const AdminStatsService();

  Future<AdminStats> load() async {
    final fs = FirebaseFirestore.instance;

    // Users
    final usersSnap = await fs.collection('users').get();
    final totalUsers = usersSnap.docs.length;
    final adminCount = usersSnap.docs
        .where((d) => (d.data())['role'] == 'admin')
        .length;
    final userCount = totalUsers - adminCount;

    // Health collections per user (best-effort)
    int stepCountDocs = 0;
    int waterIntakeDocs = 0;
    int spo2Docs = 0;
    int temperatureDocs = 0;

    // Last 7 days steps sum across all users.
    final last7DaysSteps = <String, int>{};
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));

    for (int i = 0; i < 7; i++) {
      final d = start.add(Duration(days: i));
      last7DaysSteps[_fmtDayKey(d)] = 0;
    }

    for (final userDoc in usersSnap.docs) {
      final stepAllSnap = await fs
          .collection('users')
          .doc(userDoc.id)
          .collection('step_count')
          .get();
      stepCountDocs += stepAllSnap.docs.length;

      waterIntakeDocs += (await fs
              .collection('users')
              .doc(userDoc.id)
              .collection('water_intake')
              .get())
          .docs
          .length;
      spo2Docs += (await fs
              .collection('users')
              .doc(userDoc.id)
              .collection('spo2heartrate')
              .get())
          .docs
          .length;
      temperatureDocs += (await fs
              .collection('users')
              .doc(userDoc.id)
              .collection('temperature')
              .get())
          .docs
          .length;

      for (final doc in stepAllSnap.docs) {
        final data = doc.data();
        final ts = data['timestamp'];
        final steps = (data['steps'] is num)
            ? (data['steps'] as num).toInt()
            : int.tryParse('${data['steps']}') ?? 0;

        DateTime? dt;
        if (ts is int) {
          dt = DateTime.fromMillisecondsSinceEpoch(ts);
        } else if (ts is Timestamp) {
          dt = ts.toDate();
        } else if (ts is String) {
          dt = DateTime.tryParse(ts);
        }
        if (dt == null) continue;
        if (dt.isBefore(start)) continue;

        final dayKey = _fmtDayKey(dt);
        if (!last7DaysSteps.containsKey(dayKey)) continue;
        last7DaysSteps[dayKey] = (last7DaysSteps[dayKey] ?? 0) + steps;
      }
    }

    return AdminStats(
      totalUsers: totalUsers,
      adminCount: adminCount,
      userCount: userCount,
      stepCountDocs: stepCountDocs,
      waterIntakeDocs: waterIntakeDocs,
      spo2Docs: spo2Docs,
      temperatureDocs: temperatureDocs,
      last7DaysSteps: last7DaysSteps,
    );
  }

  static String _fmtDayKey(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }
}
