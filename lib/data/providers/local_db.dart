import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/login_data_session.dart';

/// Local persistence for auth session + permissions (SQLite on mobile/desktop).
class LocalDb {
  static const _dbName = 'brain_secret.db';
  static const _dbVersion = 1;

  Database? _db;
  SharedPreferences? _prefs;

  Future<void> init() async {
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE auth_session (
            id INTEGER PRIMARY KEY NOT NULL,
            token TEXT NOT NULL,
            expires_at TEXT NOT NULL,
            user_type TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE permissions_cache (
            id INTEGER PRIMARY KEY NOT NULL,
            payload_json TEXT NOT NULL,
            synced_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveSession(LoginDataSession session) async {
    if (kIsWeb) {
      final prefs = await _ensurePrefs();
      await prefs.setString('auth_token', session.token);
      await prefs.setString('auth_expires_at', session.expiresAt);
      await prefs.setString('auth_user_type', session.userType);
      return;
    }

    final db = _requireDb();
    await db.delete('auth_session');
    await db.insert('auth_session', {
      'id': 1,
      'token': session.token,
      'expires_at': session.expiresAt,
      'user_type': session.userType,
    });
  }

  Future<LoginDataSession?> getSession() async {
    if (kIsWeb) {
      final prefs = await _ensurePrefs();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) return null;
      return LoginDataSession(
        token: token,
        expiresAt: prefs.getString('auth_expires_at') ?? '',
        userType: prefs.getString('auth_user_type') ?? '',
      );
    }

    final db = _requireDb();
    final rows = await db.query('auth_session', limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final token = row['token'] as String? ?? '';
    if (token.isEmpty) return null;
    return LoginDataSession(
      token: token,
      expiresAt: row['expires_at'] as String? ?? '',
      userType: row['user_type'] as String? ?? '',
    );
  }

  Future<void> clearSession() async {
    if (kIsWeb) {
      final prefs = await _ensurePrefs();
      await prefs.remove('auth_token');
      await prefs.remove('auth_expires_at');
      await prefs.remove('auth_user_type');
      return;
    }
    await _requireDb().delete('auth_session');
  }

  Future<void> savePermissionsPayload(Map<String, dynamic> payload) async {
    final json = jsonEncode(payload);
    final syncedAt = DateTime.now().toIso8601String();

    if (kIsWeb) {
      final prefs = await _ensurePrefs();
      await prefs.setString('permissions_payload', json);
      await prefs.setString('permissions_synced_at', syncedAt);
      return;
    }

    final db = _requireDb();
    await db.delete('permissions_cache');
    await db.insert('permissions_cache', {
      'id': 1,
      'payload_json': json,
      'synced_at': syncedAt,
    });
  }

  Future<Map<String, dynamic>?> getPermissionsPayload() async {
    if (kIsWeb) {
      final prefs = await _ensurePrefs();
      final raw = prefs.getString('permissions_payload');
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? decoded
          : Map<String, dynamic>.from(decoded as Map);
    }

    final db = _requireDb();
    final rows = await db.query('permissions_cache', limit: 1);
    if (rows.isEmpty) return null;
    final raw = rows.first['payload_json'] as String? ?? '';
    if (raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic>
        ? decoded
        : Map<String, dynamic>.from(decoded as Map);
  }

  Future<void> clearPermissions() async {
    if (kIsWeb) {
      final prefs = await _ensurePrefs();
      await prefs.remove('permissions_payload');
      await prefs.remove('permissions_synced_at');
      return;
    }
    await _requireDb().delete('permissions_cache');
  }

  Future<void> clearAll() async {
    await clearSession();
    await clearPermissions();
  }

  Database _requireDb() {
    final db = _db;
    if (db == null) {
      throw StateError('LocalDb is not initialized.');
    }
    return db;
  }

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }
}
