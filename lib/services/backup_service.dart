import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class BackupService {
  static Future<void> performLocalEncryptedBackup(String userId) async {
    final data = await _fetchUserData(userId);
    final encrypted = await _encryptData(data);
    await _saveEncryptedBackup(encrypted);
  }

  static Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    final userData = <String, dynamic>{};

    final docs = await FirebaseFirestore.instance
        .collection('documents')
        .where('userId', isEqualTo: userId)
        .get();

    userData['documents'] = docs.docs.map((doc) {
      final data = doc.data();

      // Convert Firestore Timestamps to ISO8601 strings
      data.forEach((key, value) {
        if (value is Timestamp) {
          data[key] = value.toDate().toIso8601String();
        }
      });

      return data;
    }).toList();

    return userData;
  }

  static Future<String> _encryptData(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);

    final secureStorage = FlutterSecureStorage();
    String? keyString = await secureStorage.read(key: 'backup_key');

    if (keyString == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      keyString = base64UrlEncode(key.bytes);
      await secureStorage.write(key: 'backup_key', value: keyString);
    }

    final key = encrypt.Key.fromBase64(keyString);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    return encrypted.base64;
  }

  static Future<void> _saveEncryptedBackup(String encryptedData) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup.enc');
    await file.writeAsString(encryptedData);
    if (kDebugMode) {
      print('Backup saved at: ${file.path}');
    }
  }
}

