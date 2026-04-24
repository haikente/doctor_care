import 'package:doctor_care/core/db/db_helper.dart';
import 'package:doctor_care/core/pages/custom_appbar.dart';
import 'package:doctor_care/core/services/admin_audit_service.dart';
import 'package:doctor_care/core/services/cache_manager.dart';
import 'package:doctor_care/core/services/system_config_service.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final SystemConfigService _configService = SystemConfigService();
  final AdminAuditService _auditService = AdminAuditService();
  final CacheManagerService _cacheService = CacheManagerService();

  final TextEditingController _appNameController = TextEditingController();
  final TextEditingController _minVersionController = TextEditingController();
  final TextEditingController _defaultStepGoalController =
      TextEditingController();
  final TextEditingController _defaultWaterGoalController =
      TextEditingController();
  final TextEditingController _retentionDaysController =
      TextEditingController();
  final TextEditingController _announcementController = TextEditingController();

  bool _maintenanceMode = false;
  bool _announcementEnabled = false;

  bool _isInitialLoading = true;
  bool _isSavingConfig = false;
  bool _isRunningTask = false;

  int _tempCacheSizeBytes = 0;
  SystemConfig _currentConfig = const SystemConfig();

  bool get _isBusy => _isSavingConfig || _isRunningTask;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _minVersionController.dispose();
    _defaultStepGoalController.dispose();
    _defaultWaterGoalController.dispose();
    _retentionDaysController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isInitialLoading = true);

    try {
      await _configService.initializeDefaultConfig();
      final config = await _configService.getConfig();
      final cacheSize = await _cacheService.getTempCacheSize();

      if (!mounted) return;

      _currentConfig = config;
      _applyConfigToForm(config);
      setState(() {
        _tempCacheSizeBytes = cacheSize;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Không thể tải cấu hình hệ thống: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitialLoading = false);
      }
    }
  }

  void _applyConfigToForm(SystemConfig config) {
    _appNameController.text = config.appName;
    _minVersionController.text = config.minAppVersion;
    _defaultStepGoalController.text = config.defaultStepGoal.toString();
    _defaultWaterGoalController.text = config.defaultWaterGoal.toString();
    _retentionDaysController.text = config.dataRetentionDays.toString();
    _announcementController.text = config.announcement;

    _maintenanceMode = config.maintenanceMode;
    _announcementEnabled = config.announcementEnabled;
  }

  Future<void> _refreshCacheSize() async {
    final size = await _cacheService.getTempCacheSize();
    if (!mounted) return;
    setState(() => _tempCacheSizeBytes = size);
  }

  int _parsePositiveInt(String raw, String fieldName) {
    final parsed = int.tryParse(raw.trim());
    if (parsed == null || parsed <= 0) {
      throw Exception('$fieldName phải là số nguyên dương');
    }
    return parsed;
  }

  SystemConfig _buildConfigFromForm() {
    final appName = _appNameController.text.trim();
    final minVersion = _minVersionController.text.trim();
    final announcement = _announcementController.text.trim();

    if (appName.isEmpty) {
      throw Exception('Tên ứng dụng không được để trống');
    }

    if (minVersion.isEmpty) {
      throw Exception('Phiên bản tối thiểu không được để trống');
    }

    final stepGoal = _parsePositiveInt(
      _defaultStepGoalController.text,
      'Mục tiêu bước chân mặc định',
    );
    final waterGoal = _parsePositiveInt(
      _defaultWaterGoalController.text,
      'Mục tiêu nước mặc định',
    );
    final retentionDays = _parsePositiveInt(
      _retentionDaysController.text,
      'Số ngày lưu trữ dữ liệu',
    );

    return _currentConfig.copyWith(
      appName: appName,
      minAppVersion: minVersion,
      defaultStepGoal: stepGoal,
      defaultWaterGoal: waterGoal,
      dataRetentionDays: retentionDays,
      announcement: announcement,
      announcementEnabled: _announcementEnabled,
      maintenanceMode: _maintenanceMode,
    );
  }

  Future<void> _saveConfig() async {
    if (_isBusy) return;

    FocusScope.of(context).unfocus();

    late final SystemConfig newConfig;
    try {
      newConfig = _buildConfigFromForm();
    } catch (e) {
      _showError('$e');
      return;
    }

    setState(() => _isSavingConfig = true);
    _showLoading('Đang lưu cấu hình hệ thống...');

    try {
      await _configService.updateConfig(newConfig);
      await _logConfigDiff(_currentConfig, newConfig);

      final refreshed = await _configService.getConfig();
      if (!mounted) return;

      _currentConfig = refreshed;
      _applyConfigToForm(refreshed);
      setState(() {});
      _showSuccess('Đã lưu cấu hình hệ thống');
    } catch (e) {
      if (!mounted) return;
      _showError('Lưu cấu hình thất bại: $e');
    } finally {
      if (mounted) {
        setState(() => _isSavingConfig = false);
      }
    }
  }

  Future<void> _logConfigDiff(SystemConfig oldConfig, SystemConfig newConfig) {
    final oldValues = <String, dynamic>{
      'appName': oldConfig.appName,
      'minAppVersion': oldConfig.minAppVersion,
      'defaultStepGoal': oldConfig.defaultStepGoal,
      'defaultWaterGoal': oldConfig.defaultWaterGoal,
      'dataRetentionDays': oldConfig.dataRetentionDays,
      'maintenanceMode': oldConfig.maintenanceMode,
      'announcementEnabled': oldConfig.announcementEnabled,
      'announcement': oldConfig.announcement,
    };

    final newValues = <String, dynamic>{
      'appName': newConfig.appName,
      'minAppVersion': newConfig.minAppVersion,
      'defaultStepGoal': newConfig.defaultStepGoal,
      'defaultWaterGoal': newConfig.defaultWaterGoal,
      'dataRetentionDays': newConfig.dataRetentionDays,
      'maintenanceMode': newConfig.maintenanceMode,
      'announcementEnabled': newConfig.announcementEnabled,
      'announcement': newConfig.announcement,
    };

    final futures = <Future<void>>[];
    for (final key in newValues.keys) {
      if (newValues[key] != oldValues[key]) {
        futures.add(_auditService.logUpdateConfig(key, newValues[key]));
      }
    }

    return Future.wait(futures);
  }

  Future<bool> _confirmAction({
    required String title,
    required String content,
    String confirmText = 'Thực hiện',
    bool destructive = false,
  }) async {
    final theme = Theme.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              foregroundColor: destructive
                  ? theme.colorScheme.onError
                  : theme.colorScheme.onPrimary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return ok == true;
  }

  Future<void> _runTask({
    required String loadingText,
    required String successText,
    required Future<void> Function() task,
  }) async {
    if (_isBusy) return;

    setState(() => _isRunningTask = true);
    _showLoading(loadingText);

    try {
      await task();
      if (!mounted) return;
      _showSuccess(successText);
    } catch (e) {
      if (!mounted) return;
      _showError('Lỗi: $e');
    } finally {
      if (mounted) {
        setState(() => _isRunningTask = false);
      }
    }
  }

  Future<void> _clearOldData() async {
    late final int days;
    try {
      days = _parsePositiveInt(
        _retentionDaysController.text,
        'Số ngày lưu trữ dữ liệu',
      );
    } catch (e) {
      _showError('$e');
      return;
    }

    final ok = await _confirmAction(
      title: 'Xoá dữ liệu cũ',
      content:
          'Dữ liệu cũ hơn $days ngày trong các bảng sức khoẻ local sẽ bị xoá. Dữ liệu cloud không bị ảnh hưởng.',
      confirmText: 'Xoá dữ liệu cũ',
      destructive: true,
    );

    if (!ok) return;

    await _runTask(
      loadingText: 'Đang xoá dữ liệu cũ...',
      successText: 'Đã xoá dữ liệu cũ hơn $days ngày (local)',
      task: () async {
        await DbHelper.instance.clearOldData(days);
        await _auditService.logClearOldData(days);
      },
    );
  }

  Future<void> _showAuditLogs() async {
    if (_isBusy) return;

    setState(() => _isRunningTask = true);
    _showLoading('Đang tải audit logs...');

    try {
      final logs = await _auditService.getLogs(limit: 20);
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => Container(
          height: MediaQuery.of(sheetContext).size.height * 0.78,
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const Gap(10),
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Gap(14),
              Text(
                'Audit Logs (20 gần nhất)',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Gap(10),
              Expanded(
                child: logs.isEmpty
                    ? const Center(child: Text('Chưa có bản ghi audit nào.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const Gap(8),
                        itemBuilder: (_, index) {
                          final log = logs[index];
                          final detailText =
                              (log.details == null || log.details!.isEmpty)
                              ? null
                              : log.details!.entries
                                    .map(
                                      (entry) => '${entry.key}: ${entry.value}',
                                    )
                                    .join(' | ');

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        log.action,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatDateTime(log.timestamp),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(6),
                                Text(log.description),
                                if (log.adminEmail != null) ...[
                                  const Gap(4),
                                  Text(
                                    'Admin: ${log.adminEmail}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                if (detailText != null) ...[
                                  const Gap(4),
                                  Text(
                                    detailText,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showError('Không tải được audit logs: $e');
    } finally {
      if (mounted) {
        setState(() => _isRunningTask = false);
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  void _showLoading(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomStackAppBar(
        title: 'Cấu hình hệ thống',
        centerTitle: true,
        onBack: () => Navigator.pop(context),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _isBusy ? null : _loadInitialData,
            icon: Icon(Icons.refresh, color: Colors.white,),
          ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Text(
                    'Cấu hình hệ thống Cloud + công cụ vận hành local',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Thiết lập các giá trị mặc định cho toàn hệ thống, đồng thời quản lý dữ liệu và cache trên thiết bị hiện tại.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Gap(16),

                  _SectionCard(
                    title: 'Cấu hình hệ thống (Firestore)',
                    child: Column(
                      children: [
                        _LabeledTextField(
                          label: 'Tên ứng dụng',
                          controller: _appNameController,
                          enabled: !_isBusy,
                        ),
                        const Gap(12),
                        _LabeledTextField(
                          label: 'Phiên bản tối thiểu',
                          controller: _minVersionController,
                          enabled: !_isBusy,
                        ),
                        const Gap(12),
                        Row(
                          children: [
                            Expanded(
                              child: _LabeledTextField(
                                label: 'Mục tiêu bước chân',
                                controller: _defaultStepGoalController,
                                keyboardType: TextInputType.number,
                                enabled: !_isBusy,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: _LabeledTextField(
                                label: 'Mục tiêu nước (ml)',
                                controller: _defaultWaterGoalController,
                                keyboardType: TextInputType.number,
                                enabled: !_isBusy,
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        _LabeledTextField(
                          label: 'Số ngày lưu trữ dữ liệu local',
                          controller: _retentionDaysController,
                          keyboardType: TextInputType.number,
                          enabled: !_isBusy,
                        ),
                        const Gap(12),
                        SwitchListTile(
                          value: _maintenanceMode,
                          onChanged: _isBusy
                              ? null
                              : (value) {
                                  setState(() => _maintenanceMode = value);
                                },
                          title: const Text('Chế độ bảo trì'),
                          subtitle: const Text(
                            'Bật để thông báo app đang bảo trì cho toàn bộ người dùng.',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          value: _announcementEnabled,
                          onChanged: _isBusy
                              ? null
                              : (value) {
                                  setState(() => _announcementEnabled = value);
                                },
                          title: const Text('Bật thông báo hệ thống'),
                          subtitle: const Text(
                            'Hiển thị nội dung thông báo chung trong ứng dụng.',
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const Gap(8),
                        _LabeledTextField(
                          label: 'Nội dung thông báo hệ thống',
                          controller: _announcementController,
                          enabled: !_isBusy,
                          maxLines: 3,
                        ),
                        const Gap(12),
                        if (_currentConfig.lastUpdated != null ||
                            _currentConfig.updatedBy != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Lần cập nhật gần nhất: ${_currentConfig.lastUpdated != null ? _formatDateTime(_currentConfig.lastUpdated!) : 'N/A'}'
                              '${_currentConfig.updatedBy != null ? ' | UID: ${_currentConfig.updatedBy}' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        const Gap(12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isBusy ? null : _saveConfig,
                            icon: _isSavingConfig
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _isSavingConfig
                                  ? 'Đang lưu...'
                                  : 'Lưu cấu hình hệ thống',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(16),
                  _SectionCard(
                    title: 'Quản lý dữ liệu local',
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.delete_sweep_outlined,
                          title: 'Xoá dữ liệu cũ theo retention',
                          subtitle:
                              'Xoá các bản ghi local cũ hơn số ngày lưu trữ đang cấu hình.',
                          color: Colors.deepOrange,
                          enabled: !_isBusy,
                          onTap: _clearOldData,
                        ),
                        const Gap(10),
                        _ActionTile(
                          icon: Icons.restart_alt,
                          title: 'Reset Database (Local)',
                          subtitle:
                              'Xoá database SQLite và tạo lại theo schema mới nhất.',
                          color: Colors.red,
                          enabled: !_isBusy,
                          onTap: () async {
                            final ok = await _confirmAction(
                              title: 'Reset Database (Local)',
                              content:
                                  'Thao tác này sẽ xoá toàn bộ dữ liệu cục bộ trên máy. Dữ liệu cloud (Firestore) không bị xoá.',
                              confirmText: 'Reset',
                              destructive: true,
                            );

                            if (!ok) return;

                            await _runTask(
                              loadingText: 'Đang reset database local...',
                              successText:
                                  'Reset database thành công. Hãy mở lại màn hình dữ liệu để đồng bộ lại.',
                              task: () async {
                                await DbHelper.instance.recreateDatabase();
                                await _auditService.logResetDatabase();
                              },
                            );
                          },
                        ),
                        const Gap(10),
                        _ActionTile(
                          icon: Icons.bug_report_outlined,
                          title: 'Kiểm tra schema nhanh',
                          subtitle:
                              'In danh sách bảng và schema các bảng quan trọng ra Debug Console.',
                          color: Colors.blue,
                          enabled: !_isBusy,
                          onTap: () async {
                            await _runTask(
                              loadingText: 'Đang kiểm tra schema...',
                              successText:
                                  'Đã in schema ra log (Debug Console).',
                              task: () async {
                                await DbHelper.instance.checkSchema();
                                await _auditService.logCheckSchema();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Gap(16),
                  _SectionCard(
                    title: 'Quản lý cache',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Dung lượng cache tạm ước tính: ${_cacheService.formatSize(_tempCacheSizeBytes)}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _isBusy ? null : _refreshCacheSize,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Làm mới dung lượng cache',
                            ),
                          ],
                        ),
                        const Gap(8),
                        _ActionTile(
                          icon: Icons.cleaning_services_outlined,
                          title: 'Xoá temp cache',
                          subtitle: 'Xoá file tạm trong thư mục cache của app.',
                          color: Colors.teal,
                          enabled: !_isBusy,
                          onTap: () async {
                            final ok = await _confirmAction(
                              title: 'Xoá temp cache',
                              content: 'Bạn có chắc muốn xoá temp cache?',
                              destructive: true,
                            );
                            if (!ok) return;

                            await _runTask(
                              loadingText: 'Đang xoá temp cache...',
                              successText: 'Đã xoá temp cache',
                              task: () async {
                                await _cacheService.clearTempCache();
                                await _refreshCacheSize();
                                await _auditService.logClearCache('temp_cache');
                              },
                            );
                          },
                        ),
                        const Gap(10),
                        _ActionTile(
                          icon: Icons.image_not_supported_outlined,
                          title: 'Xoá image cache (memory)',
                          subtitle:
                              'Giải phóng cache hình ảnh đang giữ trong RAM.',
                          color: Colors.indigo,
                          enabled: !_isBusy,
                          onTap: () async {
                            await _runTask(
                              loadingText: 'Đang xoá image cache...',
                              successText: 'Đã xoá image cache',
                              task: () async {
                                await _cacheService.clearImageCache();
                                await _auditService.logClearCache(
                                  'image_cache',
                                );
                              },
                            );
                          },
                        ),
                        const Gap(10),
                        _ActionTile(
                          icon: Icons.folder_delete_outlined,
                          title: 'Xoá app cache',
                          subtitle:
                              'Xoá cache ứng dụng trên bộ nhớ thiết bị (platform-dependent).',
                          color: Colors.purple,
                          enabled: !_isBusy,
                          onTap: () async {
                            final ok = await _confirmAction(
                              title: 'Xoá app cache',
                              content: 'Bạn có chắc muốn xoá app cache?',
                              destructive: true,
                            );
                            if (!ok) return;

                            await _runTask(
                              loadingText: 'Đang xoá app cache...',
                              successText: 'Đã xoá app cache',
                              task: () async {
                                await _cacheService.clearAppCache();
                                await _refreshCacheSize();
                                await _auditService.logClearCache('app_cache');
                              },
                            );
                          },
                        ),
                        const Gap(10),
                        _ActionTile(
                          icon: Icons.settings_backup_restore_outlined,
                          title: 'Xoá SharedPreferences',
                          subtitle:
                              'Xoá toàn bộ key-value cục bộ của ứng dụng.',
                          color: Colors.brown,
                          enabled: !_isBusy,
                          onTap: () async {
                            final ok = await _confirmAction(
                              title: 'Xoá SharedPreferences',
                              content:
                                  'Bạn có chắc muốn xoá toàn bộ SharedPreferences?',
                              destructive: true,
                            );
                            if (!ok) return;

                            await _runTask(
                              loadingText: 'Đang xoá SharedPreferences...',
                              successText: 'Đã xoá SharedPreferences',
                              task: () async {
                                await _cacheService.clearSharedPreferences();
                                await _auditService.logClearCache(
                                  'shared_preferences',
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const Gap(16),
                  _SectionCard(
                    title: 'Nhật ký quản trị',
                    child: _ActionTile(
                      icon: Icons.history,
                      title: 'Xem 20 audit logs gần nhất',
                      subtitle:
                          'Xem nhanh lịch sử các hành động quản trị đã ghi nhận.',
                      color: Colors.blueGrey,
                      enabled: !_isBusy,
                      onTap: _showAuditLogs,
                    ),
                  ),

                  const Gap(16),
                  _SectionCard(
                    title: 'Ghi chú',
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bullet(
                          'Sau khi sửa DB version/schema, hãy dùng Reset Database để áp dụng ngay trên máy thật.',
                        ),
                        _Bullet(
                          'Các thao tác dọn cache và reset chỉ ảnh hưởng dữ liệu local trên máy hiện tại.',
                        ),
                        _Bullet(
                          'Các thay đổi ở phần cấu hình Firestore sẽ được ghi audit log để truy vết thao tác admin.',
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(12),
          child,
        ],
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;

  const _LabeledTextField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.white : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Gap(4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: enabled ? Colors.grey.shade700 : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
