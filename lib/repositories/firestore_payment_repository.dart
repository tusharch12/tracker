import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/db_constants.dart';
import '../models/payment.dart';
import 'payment_repository.dart';

class FirestorePaymentRepository implements PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final String userId;

  FirestorePaymentRepository(this.userId);

  CollectionReference get _paymentsCollection => _firestore
      .collection('users')
      .doc(userId)
      .collection(DbConstants.paymentsTable);

  @override
  Future<Payment> create({
    required String loanId,
    required double amount,
    required DateTime paymentDate,
    String? paymentMethod,
    String? notes,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final payment = Payment(
      id: id,
      loanId: loanId,
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await _paymentsCollection.doc(id).set(payment.toMap());
    return payment;
  }

  @override
  Future<Payment?> getById(String id) async {
    final doc = await _paymentsCollection.doc(id).get();
    if (!doc.exists) return null;
    return Payment.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<Payment>> getByLoanId(String loanId) async {
    final snapshot = await _paymentsCollection
        .where(DbConstants.paymentLoanId, isEqualTo: loanId)
        .orderBy(DbConstants.paymentDate, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Payment>> getAll() async {
    final snapshot = await _paymentsCollection
        .orderBy(DbConstants.paymentDate, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Payment>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _paymentsCollection
        .where(
          DbConstants.paymentDate,
          isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
        )
        .where(
          DbConstants.paymentDate,
          isLessThanOrEqualTo: endDate.millisecondsSinceEpoch,
        )
        .orderBy(DbConstants.paymentDate, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Payment> update(Payment payment) async {
    final updatedPayment = payment.copyWith(updatedAt: DateTime.now());

    await _paymentsCollection.doc(payment.id).update(updatedPayment.toMap());
    return updatedPayment;
  }

  @override
  Future<void> delete(String id) async {
    await _paymentsCollection.doc(id).delete();
  }

  @override
  Future<double> getTotalByLoanId(String loanId) async {
    final snapshot = await _paymentsCollection
        .where(DbConstants.paymentLoanId, isEqualTo: loanId)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data[DbConstants.paymentAmount] as num).toDouble();
    }
    return total;
  }

  @override
  Future<double> getTotalAll() async {
    final snapshot = await _paymentsCollection.get();
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data[DbConstants.paymentAmount] as num).toDouble();
    }
    return total;
  }

  @override
  Future<int> getCountByLoanId(String loanId) async {
    final snapshot = await _paymentsCollection
        .where(DbConstants.paymentLoanId, isEqualTo: loanId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<Payment>> getRecent({int limit = 10}) async {
    final snapshot = await _paymentsCollection
        .orderBy(DbConstants.paymentDate, descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
