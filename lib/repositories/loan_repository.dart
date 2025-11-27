import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../core/constants/db_constants.dart';
import '../models/loan.dart';

class LoanRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // Create a new loan
  Future<Loan> create({
    required String borrowerId,
    required double principalAmount,
    required DateTime startDate,
    required double installmentAmount,
    required int installmentFrequency,
    int? totalInstallments,
    DateTime? expectedEndDate,
    String? notes,
    required double profitAmount,
    required int extraInstallments,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    final loan = Loan(
      id: _uuid.v4(),
      borrowerId: borrowerId,
      principalAmount: principalAmount,
      startDate: startDate,
      installmentAmount: installmentAmount,
      installmentFrequency: installmentFrequency,
      totalInstallments: totalInstallments,
      expectedEndDate: expectedEndDate,
      status: LoanStatus.active,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      DbConstants.loansTable,
      loan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return loan;
  }

  // Get loan by ID
  Future<Loan?> getById(String id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.loansTable,
      where: '${DbConstants.loanId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Loan.fromMap(maps.first);
  }

  // Get all loans for a borrower
  Future<List<Loan>> getByBorrowerId(String borrowerId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.loansTable,
      where: '${DbConstants.loanBorrowerId} = ?',
      whereArgs: [borrowerId],
      orderBy: '${DbConstants.loanCreatedAt} DESC',
    );

    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  // Get all loans
  Future<List<Loan>> getAll() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.loansTable,
      orderBy: '${DbConstants.loanCreatedAt} DESC',
    );

    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  // Get loans by status
  Future<List<Loan>> getByStatus(LoanStatus status) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.loansTable,
      where: '${DbConstants.loanStatus} = ?',
      whereArgs: [status.value],
      orderBy: '${DbConstants.loanCreatedAt} DESC',
    );

    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  // Get active loans for a borrower
  Future<List<Loan>> getActiveLoansByBorrowerId(String borrowerId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.loansTable,
      where:
          '${DbConstants.loanBorrowerId} = ? AND ${DbConstants.loanStatus} = ?',
      whereArgs: [borrowerId, DbConstants.statusActive],
      orderBy: '${DbConstants.loanCreatedAt} DESC',
    );

    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  // Update loan
  Future<Loan> update(Loan loan) async {
    final db = await _dbHelper.database;

    final updatedLoan = loan.copyWith(updatedAt: DateTime.now());

    await db.update(
      DbConstants.loansTable,
      updatedLoan.toMap(),
      where: '${DbConstants.loanId} = ?',
      whereArgs: [loan.id],
    );

    return updatedLoan;
  }

  // Update loan status
  Future<void> updateStatus(String id, LoanStatus status) async {
    final db = await _dbHelper.database;

    await db.update(
      DbConstants.loansTable,
      {
        DbConstants.loanStatus: status.value,
        DbConstants.loanUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${DbConstants.loanId} = ?',
      whereArgs: [id],
    );
  }

  // Delete loan (only if no payments)
  Future<bool> delete(String id) async {
    final db = await _dbHelper.database;

    // Check if loan has any payments
    final paymentCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${DbConstants.paymentsTable} WHERE ${DbConstants.paymentLoanId} = ?',
        [id],
      ),
    );

    if (paymentCount != null && paymentCount > 0) {
      return false; // Cannot delete, has payments
    }

    await db.delete(
      DbConstants.loansTable,
      where: '${DbConstants.loanId} = ?',
      whereArgs: [id],
    );

    return true;
  }

  // Get loan count by status
  Future<int> getCountByStatus(LoanStatus status) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DbConstants.loansTable} WHERE ${DbConstants.loanStatus} = ?',
      [status.value],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total principal amount by status
  Future<double> getTotalPrincipalByStatus(LoanStatus status) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT SUM(${DbConstants.loanPrincipalAmount}) FROM ${DbConstants.loansTable} WHERE ${DbConstants.loanStatus} = ?',
      [status.value],
    );

    final sum = result.first.values.first;
    return sum != null ? (sum as num).toDouble() : 0.0;
  }
}
