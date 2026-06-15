import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../modules/models/notification/notification_model.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() => _instance;

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notification_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, body TEXT, time TEXT, isRead INTEGER, readAt TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE notifications ADD COLUMN readAt TEXT');
        }
      },
    );
  }

  Future<int> insertNotification(NotificationModel notification) async {
    final db = await database;
    return await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteOldNotifications() async {
    try {
      final db = await database;


      DateTime timeLimit = DateTime.now().subtract(const Duration(minutes: 30));
      String timeLimitStr = timeLimit.toIso8601String();
      
      int deletedRead = await db.delete(
        'notifications',
        // isRead = 1 means notification is already read
        where: 'isRead = 1 AND (readAt < ? OR readAt IS NULL)',
        whereArgs: [timeLimitStr],
      );

      if (deletedRead > 0) {
        debugPrint("--- AUTO-DELETE SUCCESS: $deletedRead read notifications removed ---");
      }

      // Also delete any notification older than 24 hours
      DateTime oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
      await db.delete(
        'notifications',
        where: 'time < ?',
        whereArgs: [oneDayAgo.toIso8601String()],
      );
    } catch (e) {
      debugPrint("Error in auto-delete: $e");
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    // This will trigger the delete logic every time the list is loaded
    await deleteOldNotifications();
    
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notifications', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return NotificationModel.fromMap(maps[i]);
    });
  }

  Future<int> markAsRead(int id) async {
    final db = await database;
    String now = DateTime.now().toIso8601String();
    debugPrint("Marking notification $id as read at $now");
    
    return await db.update(
      'notifications',
      {
        'isRead': 1,
        'readAt': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAllNotifications() async {
    final db = await database;
    return await db.delete('notifications');
  }
}
