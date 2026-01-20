# 🔐 HƯỚNG DẪN TẠO VÀ QUẢN LÝ ADMIN ROLE

## 📋 Mục lục
1. [Cách 1: Tạo Admin qua Firebase Console](#cách-1-firebase-console)
2. [Cách 2: Sử dụng Admin Setup Screen](#cách-2-admin-setup-screen)
3. [Cách 3: Chạy Script trực tiếp](#cách-3-script-trực-tiếp)
4. [Xác minh Role Admin](#xác-minh-role-admin)
5. [Quản lý Permissions](#quản-lý-permissions)

---

## Cách 1: Firebase Console (Khuyến nghị cho Production)

### Bước 1: Tạo User trong Firebase Authentication
1. Mở **Firebase Console**: https://console.firebase.google.com
2. Chọn project **Doctor Care**
3. Vào **Authentication** → **Users**
4. Click **Add User**
5. Nhập:
   - Email: `admin@doctorcare.com`
   - Password: `Admin@123` (hoặc mật khẩu mạnh hơn)
6. Click **Add User**
7. **Copy UID** của user (cột User UID)

### Bước 2: Thêm Role vào Firestore
1. Vào **Firestore Database**
2. Vào collection `users` (tạo mới nếu chưa có)
3. Click **Add Document**
4. **Document ID**: Paste **UID** từ bước 1
5. Thêm fields:
```
Field               Type      Value
uid                 string    [paste UID here]
email               string    admin@doctorcare.com
role                string    admin
createdAt           timestamp [current time]
```
6. Click **Save**

### Bước 3: Test
1. Mở app → Login với `admin@doctorcare.com`
2. Check role trong database

---

## Cách 2: Admin Setup Screen (Khuyến nghị cho Development)

### Setup Route

**Thêm vào `lib/main.dart`:**

```dart
import 'package:doctor_care/presentation/pages/screens/admin/admin_setup_screen.dart';

// Trong MaterialApp routes:
routes: {
  '/navigation': (context) => const Navigationbar(),
  '/bloodpressure': (context) => const BloodPressureScreen(),
  '/admin-setup': (context) => const AdminSetupScreen(), // ⚠️ CHỈ DÙNG 1 LẦN
},
```

### Truy cập màn hình

**Option A: Thêm button tạm vào Login Screen:**

```dart
// Trong login_screen.dart, thêm dưới nút "Đăng ký":
const Gap(16),
TextButton(
  onPressed: () {
    Navigator.pushNamed(context, '/admin-setup');
  },
  child: const Text(
    '🔐 Admin Setup (Dev Only)',
    style: TextStyle(color: Colors.red),
  ),
),
```

**Option B: Navigate trực tiếp:**

```dart
// Trong bất kỳ màn hình nào:
Navigator.pushNamed(context, '/admin-setup');
```

### Sử dụng màn hình

1. Mở app → Login Screen
2. Bấm "🔐 Admin Setup"
3. Nhập **Secret Key**: `DOCTORCARE_ADMIN_2026`
4. Nhập email: `admin@doctorcare.com`
5. Nhập password: `Admin@123`
6. Chọn một trong hai:

   **A. Tạo Admin Mới:**
   - Bấm "Tạo Admin Mới"
   - User mới sẽ được tạo với role admin

   **B. Nâng cấp User hiện có:**
   - Chỉ nhập email (không cần password)
   - Bấm "Nâng cấp User hiện có"
   - User đã tồn tại sẽ được promote thành admin

### ⚠️ BẢO MẬT - SAU KHI HOÀN THÀNH

**QUAN TRỌNG:** Xóa màn hình này khỏi production!

```bash
# 1. Xóa file
rm lib/presentation/pages/screens/admin/admin_setup_screen.dart

# 2. Xóa route trong main.dart
# Xóa dòng: '/admin-setup': (context) => const AdminSetupScreen(),

# 3. Xóa import trong main.dart
# Xóa: import 'package:doctor_care/presentation/pages/screens/admin/admin_setup_screen.dart';

# 4. Rebuild app
flutter clean
flutter pub get
flutter run
```

---

## Cách 3: Script trực tiếp (Cho Developer)

### Tạo file script

**`scripts/create_admin.dart`:**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await Firebase.initializeApp();
  
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  
  // Thay đổi email và password
  const email = 'admin@doctorcare.com';
  const password = 'Admin@123';
  
  try {
    // Tạo user
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final user = userCredential.user!;
    
    // Thêm role admin
    await firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ Admin created successfully!');
    print('Email: $email');
    print('UID: ${user.uid}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Chạy script

```bash
dart run scripts/create_admin.dart
```

---

## Xác minh Role Admin

### Kiểm tra trong Firestore
1. Mở **Firebase Console** → **Firestore**
2. Vào collection `users`
3. Tìm document với email admin
4. Xác nhận field `role` = `"admin"`

### Kiểm tra trong App

**Thêm vào Profile Screen hoặc Debug Screen:**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> checkUserRole() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  
  final role = doc.data()?['role'] ?? 'patient';
  
  print('Current user role: $role');
  print('Is Admin: ${role == 'admin'}');
}
```

### Test Role-based Features

```dart
// Trong bất kỳ màn hình nào
FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .get(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final role = snapshot.data?.get('role') ?? 'patient';
    
    if (role == 'admin') {
      return AdminPanel(); // Hiển thị admin panel
    } else {
      return PatientView(); // Hiển thị patient view
    }
  },
)
```

---

## Quản lý Permissions

### Định nghĩa Roles

```dart
// lib/core/constants/roles.dart
class UserRole {
  static const String admin = 'admin';
  static const String doctor = 'doctor';
  static const String patient = 'patient';
}
```

### Permission Helper

```dart
// lib/core/helpers/permission_helper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PermissionHelper {
  static Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    return doc.data()?['role'] == 'admin';
  }
  
  static Future<String> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'patient';
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    
    return doc.data()?['role'] ?? 'patient';
  }
}
```

### Sử dụng Permissions

```dart
// Kiểm tra trước khi hiển thị admin features
final isAdmin = await PermissionHelper.isAdmin();

if (isAdmin) {
  // Hiển thị admin features
  showAdminPanel();
} else {
  // Hiển thị error
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Truy cập bị từ chối'),
      content: Text('Bạn không có quyền truy cập chức năng này.'),
    ),
  );
}
```

---

## Firestore Security Rules

**Cập nhật `firestore.rules`:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users collection
    match /users/{userId} {
      // Chỉ admin hoặc chính user đó mới đọc được
      allow read: if request.auth.uid == userId || isAdmin();
      
      // Chỉ admin mới sửa được role
      allow update: if isAdmin() || (request.auth.uid == userId && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['role']));
      
      // Admin có thể tạo user với bất kỳ role nào
      allow create: if isAdmin();
    }
    
    // Admin-only collections
    match /admin_data/{document=**} {
      allow read, write: if isAdmin();
    }
  }
}
```

---

## Troubleshooting

### Admin không có quyền truy cập?

1. **Kiểm tra role trong Firestore:**
   ```
   Collection: users
   Document ID: [user UID]
   Field: role = "admin"
   ```

2. **Kiểm tra UID khớp:**
   - UID trong Authentication
   - Document ID trong Firestore
   - Phải giống nhau!

3. **Re-login:**
   - Đăng xuất
   - Đăng nhập lại
   - Check role mới

### Email đã tồn tại?

```dart
// Promote user hiện có thay vì tạo mới
final querySnapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: 'admin@doctorcare.com')
    .limit(1)
    .get();

if (querySnapshot.docs.isNotEmpty) {
  final docId = querySnapshot.docs.first.id;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(docId)
      .update({'role': 'admin'});
}
```

---

## Best Practices

✅ **DO:**
- Sử dụng Secret Key mạnh
- Xóa Admin Setup Screen sau khi dùng xong
- Set Firestore Security Rules
- Log tất cả admin actions
- Sử dụng Environment Variables cho Secret Key

❌ **DON'T:**
- Để Admin Setup Screen trong production
- Hardcode admin credentials
- Cho phép tự promote thành admin trong app
- Skip validation cho admin actions

---

## Summary

| Cách | Ưu điểm | Nhược điểm | Khuyến nghị |
|------|---------|-----------|-------------|
| Firebase Console | Bảo mật cao | Thủ công | Production |
| Admin Setup Screen | Dễ dùng | Phải xóa sau | Development |
| Script | Tự động hóa | Cần setup | CI/CD |

**Recommended Flow:**
1. Development: Dùng Admin Setup Screen
2. Staging: Dùng Firebase Console
3. Production: Dùng Firebase Console + Cloud Functions

---

**🔐 BẢO MẬT LÀ QUAN TRỌNG NHẤT!**
