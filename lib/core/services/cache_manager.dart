import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý cache local của ứng dụng
class CacheManagerService {
  static final CacheManagerService _instance = CacheManagerService._internal();
  factory CacheManagerService() => _instance;
  CacheManagerService._internal();

  /// Xóa image cache trong bộ nhớ
  Future<void> clearImageCache() async {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      print('🖼️ Image cache cleared');
    } catch (e) {
      print('❌ Error clearing image cache: $e');
      throw Exception('Không thể xóa image cache: $e');
    }
  }

  /// Xóa toàn bộ SharedPreferences
  Future<void> clearSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('🔧 SharedPreferences cleared');
    } catch (e) {
      print('❌ Error clearing SharedPreferences: $e');
      throw Exception('Không thể xóa SharedPreferences: $e');
    }
  }

  /// Xóa cache files trong thư mục tạm
  Future<void> clearTempCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      await _deleteContents(tempDir);
      print('🗑️ Temp cache cleared');
    } catch (e) {
      print('❌ Error clearing temp cache: $e');
      throw Exception('Không thể xóa temp cache: $e');
    }
  }

  /// Xóa cache ứng dụng (app-specific cache)
  Future<void> clearAppCache() async {
    try {
      if (Platform.isAndroid) {
        final cacheDir = await getTemporaryDirectory();
        await _deleteContents(cacheDir);
      } else if (Platform.isIOS) {
        final cacheDir = await getLibraryDirectory();
        final flutterCacheDir = Directory('${cacheDir.path}/flutter');
        if (await flutterCacheDir.exists()) {
          await _deleteContents(flutterCacheDir);
        }
      }
      print('📱 App cache cleared');
    } catch (e) {
      print('❌ Error clearing app cache: $e');
      throw Exception('Không thể xóa app cache: $e');
    }
  }

  /// Lấy kích thước cache tạm thời (bytes)
  Future<int> getTempCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      return await _calculateSize(tempDir);
    } catch (e) {
      print('❌ Error calculating cache size: $e');
      return 0;
    }
  }

  /// Định dạng kích thước file thành string đọc được
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // === Private helpers ===

  Future<void> _deleteContents(Directory dir) async {
    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      try {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      } catch (e) {
        print('⚠️ Could not delete ${entity.path}: $e');
      }
    }
  }

  Future<int> _calculateSize(Directory dir) async {
    int totalSize = 0;
    if (!await dir.exists()) return 0;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }
}
