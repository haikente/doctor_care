import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

   static Future<String?> uploadImage({
    required File imageFile,
    required String userId,
    required Function(double) onProgress,
  }) async {
    try {
      // Create unique filename
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('user_profiles/$fileName');

      // Upload file
      final UploadTask uploadTask = ref.putFile(imageFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Update user profile photo URL in Firestore
  static Future<bool> updateUserProfilePhoto({
    required String userId,
    required String photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profilePhotoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating profile photo: $e');
      return false;
    }
  }

  /// Delete old profile photo from storage
  static Future<void> deleteOldProfilePhoto(String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final Reference ref = _storage.ref().child('user_profiles/$fileName');
      await ref.delete();
    } catch (e) {
      print('Error deleting old photo: $e');
      // Ignore error if file doesn't exist
    }
  }

  /// Complete upload process: pick, upload, and update Firestore
  static Future<String?> uploadProfilePhoto({
    required String userId,
    required ImageSource source,
    required Function(double) onProgress,
  }) async {
    try {
      // Pick image
      final File? imageFile = source == ImageSource.gallery
          ? await pickImageFromGallery()
          : await pickImageFromCamera();

      if (imageFile == null) {
        return null;
      }

      // Delete old photo (if exists)
      await deleteOldProfilePhoto(userId);

      // Upload new photo
      final String? downloadUrl = await uploadImage(
        imageFile: imageFile,
        userId: userId,
        onProgress: onProgress,
      );

      if (downloadUrl == null) {
        return null;
      }

      // Update Firestore
      final bool success = await updateUserProfilePhoto(
        userId: userId,
        photoUrl: downloadUrl,
      );

      if (success) {
        return downloadUrl;
      }
      return null;
    } catch (e) {
      print('Error in upload process: $e');
      return null;
    }
  }
}
