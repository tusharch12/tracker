import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../core/constants/db_constants.dart';
import '../models/borrower.dart';

class BorrowerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // Create a new borrower
  Future<Borrower> create({
    required String name,
    String? phone,
    String? email,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    final borrower = Borrower(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      email: email,
      notes: notes,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      DbConstants.borrowersTable,
      borrower.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return borrower;
  }

  // Get borrower by ID
  Future<Borrower?> getById(String id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.borrowersTable,
      where: '${DbConstants.borrowerId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Borrower.fromMap(maps.first);
  }

  // Get all borrowers (excluding soft deleted)
  Future<List<Borrower>> getAll({bool includeDeleted = false}) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.borrowersTable,
      where: includeDeleted ? null : '${DbConstants.borrowerIsDeleted} = ?',
      whereArgs: includeDeleted ? null : [0],
      orderBy: '${DbConstants.borrowerName} ASC',
    );

    return maps.map((map) => Borrower.fromMap(map)).toList();
  }

  // Search borrowers by name
  Future<List<Borrower>> search(String query) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.borrowersTable,
      where: '${DbConstants.borrowerName} LIKE ? AND ${DbConstants.borrowerIsDeleted} = ?',
      whereArgs: ['%$query%', 0],
      orderBy: '${DbConstants.borrowerName} ASC',
    );

    return maps.map((map) => Borrower.fromMap(map)).toList();
  }

  // Update borrower
  Future<Borrower> update(Borrower borrower) async {
    final db = await _dbHelper.database;

    final updatedBorrower = borrower.copyWith(
      updatedAt: DateTime.now(),
    );

    await db.update(
      DbConstants.borrowersTable,
      updatedBorrower.toMap(),
      where: '${DbConstants.borrowerId} = ?',
      whereArgs: [borrower.id],
    );

    return updatedBorrower;
  }

  // Soft delete borrower
  Future<void> softDelete(String id) async {
    final db = await _dbHelper.database;

    await db.update(
      DbConstants.borrowersTable,
      {
        DbConstants.borrowerIsDeleted: 1,
        DbConstants.borrowerUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DbConstants.borrowerId} = ?',
      whereArgs: [id],
    );
  }

  // Restore soft deleted borrower
  Future<void> restore(String id) async {
    final db = await _dbHelper.database;

    await db.update(
      DbConstants.borrowersTable,
      {
        DbConstants.borrowerIsDeleted: 0,
        DbConstants.borrowerUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DbConstants.borrowerId} = ?',
      whereArgs: [id],
    );
  }

  // Hard delete borrower (only if no active loans)
  Future<bool> hardDelete(String id) async {
    final db = await _dbHelper.database;

    // Check if borrower has any loans
    final loanCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${DbConstants.loansTable} WHERE ${DbConstants.loanBorrowerId} = ?',
        [id],
      ),
    );

    if (loanCount != null && loanCount > 0) {
      return false; // Cannot delete, has active loans
    }

    await db.delete(
      DbConstants.borrowersTable,
      where: '${DbConstants.borrowerId} = ?',
      whereArgs: [id],
    );

    return true;
  }

  // Get borrower count
  Future<int> getCount({bool includeDeleted = false}) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DbConstants.borrowersTable}${includeDeleted ? '' : ' WHERE ${DbConstants.borrowerIsDeleted} = 0'}',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
