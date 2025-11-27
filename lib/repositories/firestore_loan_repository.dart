import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/db_constants.dart';
import '../models/loan.dart';
import 'loan_repository.dart';

class FirestoreLoanRepository implements LoanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final String userId;

  FirestoreLoanRepository(this.userId);

  CollectionReference get _loansCollection => _firestore
      .collection('users')
      .doc(userId)
      .collection(DbConstants.loansTable);

  @override
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
    final now = DateTime.now();
    final id = _uuid.v4();

    final loan = Loan(
      id: id,
      borrowerId: borrowerId,
      principalAmount: principalAmount,
      startDate: startDate,
      installmentAmount: installmentAmount,
      installmentFrequency: installmentFrequency,
      totalInstallments: totalInstallments,
      expectedEndDate: expectedEndDate,
      status: LoanStatus.active,
      notes: notes,
      profitAmount: profitAmount,
      extraInstallments: extraInstallments,
      createdAt: now,
      updatedAt: now,
    );

    await _loansCollection.doc(id).set(loan.toMap());
    return loan;
  }

  @override
  Future<Loan?> getById(String id) async {
    final doc = await _loansCollection.doc(id).get();
    if (!doc.exists) return null;
    return Loan.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<Loan>> getAll() async {
    final snapshot = await _loansCollection
        .orderBy(DbConstants.loanCreatedAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Loan.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Loan>> getByBorrowerId(String borrowerId) async {
    final snapshot = await _loansCollection
        .where(DbConstants.loanBorrowerId, isEqualTo: borrowerId)
        .orderBy(DbConstants.loanCreatedAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Loan.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Loan>> getByStatus(LoanStatus status) async {
    final snapshot = await _loansCollection
        .where(DbConstants.loanStatus, isEqualTo: status.value)
        .orderBy(DbConstants.loanCreatedAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Loan.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Loan>> getActiveLoansByBorrowerId(String borrowerId) async {
    final snapshot = await _loansCollection
        .where(DbConstants.loanBorrowerId, isEqualTo: borrowerId)
        .where(DbConstants.loanStatus, isEqualTo: DbConstants.statusActive)
        .orderBy(DbConstants.loanCreatedAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Loan.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Loan> update(Loan loan) async {
    final updatedLoan = loan.copyWith(updatedAt: DateTime.now());

    await _loansCollection.doc(loan.id).update(updatedLoan.toMap());
    return updatedLoan;
  }

  @override
  Future<void> updateStatus(String id, LoanStatus status) async {
    await _loansCollection.doc(id).update({
      DbConstants.loanStatus: status.value,
      DbConstants.loanUpdatedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<bool> delete(String id) async {
    // Check for payments
    final paymentsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(DbConstants.paymentsTable)
        .where(DbConstants.paymentLoanId, isEqualTo: id)
        .limit(1)
        .get();

    if (paymentsSnapshot.docs.isNotEmpty) {
      return false;
    }

    await _loansCollection.doc(id).delete();
    return true;
  }

  @override
  Future<int> getCountByStatus(LoanStatus status) async {
    final snapshot = await _loansCollection
        .where(DbConstants.loanStatus, isEqualTo: status.value)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Future<double> getTotalPrincipalByStatus(LoanStatus status) async {
    final snapshot = await _loansCollection
        .where(DbConstants.loanStatus, isEqualTo: status.value)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data[DbConstants.loanPrincipalAmount] as num).toDouble();
    }
    return total;
  }

  // Helper methods / Legacy methods (removed @override as they are not in LoanRepository)
  Future<double> getTotalPrincipal() async {
    final snapshot = await _loansCollection.get();
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data[DbConstants.loanPrincipalAmount] as num).toDouble();
    }
    return total;
  }

  Future<double> getTotalActivePrincipal() async {
    final snapshot = await _loansCollection
        .where(DbConstants.loanStatus, isEqualTo: DbConstants.statusActive)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data[DbConstants.loanPrincipalAmount] as num).toDouble();
    }
    return total;
  }

  Future<int> getActiveLoanCount() async {
    final snapshot = await _loansCollection
        .where(DbConstants.loanStatus, isEqualTo: DbConstants.statusActive)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
