# 🔧 Fix Google Sign In - DEVELOPER_ERROR

## Vấn Đề
```
ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null}
```

Nguyên nhân: **File `google-services.json` thiếu OAuth Client ID**

## ✅ Giải Pháp - Cấu Hình Firebase Console

### Bước 1: Tạo OAuth Client ID

1. Vào **Firebase Console**: https://console.firebase.google.com
2. Chọn project: **drcare-90960**
3. Vào **Project Settings** (⚙️ góc trên trái)
4. Tab **General** → Tìm phần **Your apps** → Android app
5. Click **Add fingerprint** (nếu chưa có)

### Bước 2: Lấy SHA-1 Certificate Fingerprint

Mở terminal và chạy:

```powershell
cd c:\Users\OS\.vscode\test\Docter_care\doctor_care\android
./gradlew signingReport
```

Hoặc nếu lỗi, dùng keytool:

```powershell
# Debug keystore (cho development)
keytool -list -v -keystore $env:USERPROFILE\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy **SHA-1** fingerprint (giống: `AA:BB:CC:DD:...`)

### Bước 3: Thêm SHA-1 vào Firebase

1. Quay lại Firebase Console → Your apps → Android app
2. Click **Add fingerprint**
3. Paste SHA-1 fingerprint vừa copy
4. Click **Save**

### Bước 4: Enable Google Sign In

1. Trong Firebase Console, vào **Authentication**
2. Tab **Sign-in method**
3. Tìm **Google** → Click vào
4. Toggle **Enable**
5. Chọn **Support email** (email của bạn)
6. Click **Save**

### Bước 5: Download google-services.json mới

1. Quay lại **Project Settings** → **Your apps**
2. Click nút **Download google-services.json** (⬇️)
3. Copy file mới vào: `android/app/google-services.json`
4. **Overwrite** file cũ

### Bước 6: Verify google-services.json

File mới phải có `oauth_client` array với data:

```json
{
  "client": [
    {
      "oauth_client": [
        {
          "client_id": "972427288907-xxxxxxxxxxxx.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.example.doctor_care",
            "certificate_hash": "abcdef1234567890..."
          }
        },
        {
          "client_id": "972427288907-xxxxxxxxxxxx.apps.googleusercontent.com",
          "client_type": 3
        }
      ]
    }
  ]
}
```

### Bước 7: Rebuild App

```powershell
cd c:\Users\OS\.vscode\test\Docter_care\doctor_care
flutter clean
flutter pub get
flutter run
```

## 🎯 Giải Thích Lỗi

- **DEVELOPER_ERROR**: Firebase không tìm thấy OAuth client matching với app signature
- **oauth_client: []**: File `google-services.json` chưa có cấu hình OAuth
- **Cần SHA-1**: Firebase dùng SHA-1 để verify app authenticity

## ⚠️ Lưu Ý

### Debug vs Release Build
- **Debug keystore**: Dùng cho `flutter run` (development)
- **Release keystore**: Dùng cho production (cần tạo riêng)
- Cần add **cả 2 SHA-1** vào Firebase nếu test cả debug và release

### SHA-1 Location
- Debug keystore: `%USERPROFILE%\.android\debug.keystore`
- Release keystore: Tự tạo (xem Flutter docs)

### Package Name Match
Đảm bảo package name trong:
- `google-services.json`: `"package_name": "com.example.doctor_care"`
- `android/app/build.gradle.kts`: `applicationId = "com.example.doctor_care"`
- Phải **giống hệt nhau**

## 🧪 Test Sau Khi Fix

1. Login bằng email/password admin → Xem có vào Admin Panel không
2. Logout
3. Thử Google Sign In → Phải hiện account picker
4. Check log không còn DEVELOPER_ERROR

## 📚 Reference

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Sign In Flutter](https://pub.dev/packages/google_sign_in)
- [SHA-1 Certificate](https://developers.google.com/android/guides/client-auth)
