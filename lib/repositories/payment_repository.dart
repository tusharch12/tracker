import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../core/constants/db_constants.dart';
import '../models/payment.dart';

class PaymentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // Create a new payment
  Future<Payment> create({
    required String loanId,
    required double amount,
    required DateTime paymentDate,
    String? paymentMethod,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    final payment = Payment(
      id: _uuid.v4(),
      loanId: loanId,
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      DbConstants.paymentsTable,
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return payment;
  }

  // Get payment by ID
  Future<Payment?> getById(String id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.paymentsTable,
      where: '${DbConstants.paymentId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Payment.fromMap(maps.first);
  }

  // Get all payments for a loan
  Future<List<Payment>> getByLoanId(String loanId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.paymentsTable,
      where: '${DbConstants.paymentLoanId} = ?',
      whereArgs: [loanId],
      orderBy: '${DbConstants.paymentDate} DESC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  // Get all payments
  Future<List<Payment>> getAll() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.paymentsTable,
      orderBy: '${DbConstants.paymentDate} DESC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  // Get payments within date range
  Future<List<Payment>> getByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.paymentsTable,
      where: '${DbConstants.paymentDate} BETWEEN ? AND ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: '${DbConstants.paymentDate} DESC',
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  // Update payment
  Future<Payment> update(Payment payment) async {
    final db = await _dbHelper.database;

    final updatedPayment = payment.copyWith(
      updatedAt: DateTime.now(),
    );

    await db.update(
      DbConstants.paymentsTable,
      updatedPayment.toMap(),
      where: '${DbConstants.paymentId} = ?',
      whereArgs: [payment.id],
    );

    return updatedPayment;
  }

  // Delete payment
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;

    await db.delete(
      DbConstants.paymentsTable,
      where: '${DbConstants.paymentId} = ?',
      whereArgs: [id],
    );
  }

  // Get total payments for a loan
  Future<double> getTotalByLoanId(String loanId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT SUM(${DbConstants.paymentAmount}) FROM ${DbConstants.paymentsTable} WHERE ${DbConstants.paymentLoanId} = ?',
      [loanId],
    );

    final sum = result.first.values.first;
    return sum != null ? (sum as num).toDouble() : 0.0;
  }

  // Get total payments across all loans
  Future<double> getTotalAll() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT SUM(${DbConstants.paymentAmount}) FROM ${DbConstants.paymentsTable}',
    );

    final sum = result.first.values.first;
    return sum != null ? (sum as num).toDouble() : 0.0;
  }

  // Get payment count for a loan
  Future<int> getCountByLoanId(String loanId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DbConstants.paymentsTable} WHERE ${DbConstants.paymentLoanId} = ?',
      [loanId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get recent payments (limit)
  Future<List<Payment>> getRecent({int limit = 10}) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      DbConstants.paymentsTable,
      orderBy: '${DbConstants.paymentDate} DESC',
      limit: limit,
    );

    return maps.map((map) => Payment.fromMap(map)).toList();
  }
}
