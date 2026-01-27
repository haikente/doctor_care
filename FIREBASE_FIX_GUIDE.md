# 🚨 Khắc phục lỗi SecurityException - Google API Manager

## ⚠️ Lỗi nghiêm trọng!

```
E/GoogleApiManager: java.lang.SecurityException: Unknown calling package name 'com.google.android.gms'
W/GoogleApiManager: ConnectionResult{statusCode=DEVELOPER_ERROR}
```

**Hậu quả:** Không thể đăng nhập với Google Sign-In, Firebase Auth bị lỗi.

## 🔍 Nguyên nhân
1. **SHA-1 fingerprint chưa được thêm vào Firebase Console** ⛔
2. Google Sign-In chưa được cấu hình đúng
3. File `google-services.json` thiếu OAuth Client (mảng rỗng)

---

## 🔧 Cách khắc phục (BẮT BUỘC)

### ✅ Bước 1: SHA-1 Fingerprint của bạn (ĐÃ LẤY)

**Debug SHA-1:**
```
6E:CC:D1:A9:FB:3B:8B:4E:B2:7E:11:D5:18:8C:F0:C6:89:B6:02:95
```

**SHA-256:**
```
33:04:C6:8D:FB:9C:A8:14:F7:DC:BA:A7:21:4D:90:FE:57:70:F2:E0:D9:06:DD:E4:A5:F0:4F:50:0B:EC:71:4E
```

**Package name:**
```
com.example.doctor_care
```

---

### 🌐 Bước 2: Thêm SHA-1 vào Firebase Console

1. **Truy cập Firebase Console:**
   - URL: https://console.firebase.google.com/
   - Chọn project: **drcare-90960**

2. **Vào Project Settings:**
   - Click vào icon ⚙️ (góc trên bên trái)
   - Chọn **Project settings**

3. **Chọn Android App:**
   - Scroll xuống phần **Your apps**
   - Tìm app: `com.example.doctor_care` (Android)

4. **Thêm SHA Fingerprints:**
   - Scroll xuống phần **SHA certificate fingerprints**
   - Click **Add fingerprint**
   - Dán SHA-1: `6E:CC:D1:A9:FB:3B:8B:4E:B2:7E:11:D5:18:8C:F0:C6:89:B6:02:95`
   - Click **Save**
   
5. **Thêm SHA-256 (khuyến nghị):**
   - Click **Add fingerprint** lần nữa
   - Dán SHA-256: `33:04:C6:8D:FB:9C:A8:14:F7:DC:BA:A7:21:4D:90:FE:57:70:F2:E0:D9:06:DD:E4:A5:F0:4F:50:0B:EC:71:4E`
   - Click **Save**

---

### 🔐 Bước 3: Enable Google Sign-In

1. **Trong Firebase Console:**
   - Vào **Authentication** (menu bên trái)
   - Tab **Sign-in method**

2. **Enable Google:**
   - Tìm **Google** trong danh sách providers
   - Click vào **Google**
   - Toggle **Enable** → ON
   - Nhập **Project support email** (email admin của bạn)
   - Click **Save**

---

### 📥 Bước 4: Download google-services.json mới

1. **Quay lại Project Settings:**
   - Click ⚙️ → **Project settings**
   - Chọn app `com.example.doctor_care`

2. **Download file mới:**
   - Scroll xuống phần **Your apps**
   - Click **Download google-services.json**

3. **Thay thế file cũ:**
   - Copy file vừa download
   - Paste vào: `android/app/google-services.json`
   - **Overwrite** file cũ

4. **Xác nhận OAuth Client:**
   Mở file `google-services.json` và kiểm tra:
   ```json
   "oauth_client": [
     {
       "client_id": "xxx.apps.googleusercontent.com",
       "client_type": 3
     }
   ]
   ```
   ✅ Phải có ít nhất 1 client, không còn mảng rỗng `[]`

---

### 🧹 Bước 5: Clean và Rebuild

**Trong terminal:**

```powershell
# Xóa cache
flutter clean

# Cài lại dependencies
flutter pub get

# Clean Android build
cd android
.\gradlew.bat clean
cd ..

# Run app
flutter run
```

**Hoặc ngắn gọn:**
```powershell
flutter clean ; flutter pub get ; flutter run
```

---

## ✅ Kiểm tra kết quả

1. **Chạy lại app:**
   ```powershell
   flutter run
   ```

2. **Kiểm tra logs:**
   - Không còn lỗi: `SecurityException: Unknown calling package name`
   - Không còn: `ConnectionResult{statusCode=DEVELOPER_ERROR}`

3. **Test Google Sign-In:**
   - Thử đăng nhập bằng Google
   - Phải hiện popup chọn tài khoản Google
   - Đăng nhập thành công

---

## 🔄 Nếu vẫn lỗi

### Giải pháp 1: Xóa app và cài lại

```powershell
# Gỡ app khỏi thiết bị/emulator
flutter clean

# Cài lại từ đầu
flutter run
```

### Giải pháp 2: Kiểm tra Google Play Services

**Trên emulator:**
- Settings → Apps → Google Play Services → **Update**
- Hoặc tạo emulator mới với Play Store enabled

**Trên thiết bị thật:**
- Vào CH Play → Update Google Play Services

### Giải pháp 3: Xác nhận lại SHA-1

Nếu chạy trên thiết bị thật và build **Release**, cần SHA-1 của **release keystore**:

```powershell
# Lấy SHA-1 release (nếu có keystore.jks)
cd android
.\gradlew.bat signingReport
```

Tìm phần **Variant: release** và copy SHA-1 đó thêm vào Firebase.

---

## 📝 Tóm tắt

| Bước | Hành động | Trạng thái |
|------|-----------|------------|
| 1 | Lấy SHA-1 fingerprint | ✅ Xong |
| 2 | Thêm SHA-1 vào Firebase Console | ⏳ Cần làm |
| 3 | Enable Google Sign-In | ⏳ Cần làm |
| 4 | Download google-services.json mới | ⏳ Cần làm |
| 5 | Clean và rebuild | ⏳ Cần làm |

---

## 💡 Lưu ý quan trọng

- **SHA-1 debug** chỉ dùng cho development
- Khi build release, phải dùng SHA-1 của **release keystore**
- Mỗi máy dev khác nhau có SHA-1 khác nhau (nếu dùng debug keystore)
- Có thể thêm nhiều SHA-1 vào Firebase (cho nhiều máy dev)

---

## 🆘 Nếu cần hỗ trợ

**Câu hỏi thường gặp:**

**Q: Tôi không tìm thấy ⚙️ icon trong Firebase Console?**  
A: Nó ở góc trên bên trái, cạnh tên project "drcare-90960"

**Q: Không thấy option "Add fingerprint"?**  
A: Đảm bảo đã chọn đúng Android app `com.example.doctor_care`

**Q: File google-services.json vẫn có oauth_client rỗng?**  
A: Chờ 1-2 phút sau khi enable Google Sign-In, sau đó download lại

**Q: Vẫn lỗi sau khi làm tất cả?**  
A: Thử gỡ app hoàn toàn, flutter clean, và cài lại từ đầu
