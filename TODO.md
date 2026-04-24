# P0 Admin Features Implementation

## Scope: Admin + User only (no Doctor role)

## Tasks

### Phase 1: Search & Filter Users
- [ ] `admin_panel_screen.dart`: Add StatefulBuilder to `_showUsersList`
- [ ] `admin_panel_screen.dart`: Add search TextField (filter by name/email/phone)
- [ ] `admin_panel_screen.dart`: Add filter chips (Tất cả / Admin / Người dùng)
- [ ] `admin_panel_screen.dart`: Apply search + filter logic to user list

### Phase 2: Enable/Disable User Accounts
- [ ] `role_service.dart`: Add `toggleUserActiveStatus()` method
- [ ] `admin_audit_service.dart`: Add `logToggleUserStatus()` method
- [ ] `usercase.dart`: Add `showToggleUserStatusDialog()` method
- [ ] `admin_panel_screen.dart`: Show `isActive` status on user cards
- [ ] `admin_panel_screen.dart`: Add Khóa/Mở khóa button in user actions

### Phase 3: View User Health Data
- [ ] `admin_audit_service.dart`: Add `logViewHealthData()` method
- [ ] `usercase.dart`: Replace `showHealthData()` placeholder with real implementation
- [ ] `usercase.dart`: Create bottom sheet showing user's health subcollections from Firestore
- [ ] `admin_panel_screen.dart`: Add "Xem dữ liệu SK" button to user card actions

### Phase 4: Integration & Polish
- [ ] Verify all audit logs work correctly
- [ ] Test UI flow end-to-end
