import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/db_constants.dart';
import '../models/borrower.dart';
import 'borrower_repository.dart';

class FirestoreBorrowerRepository implements BorrowerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final String userId;

  FirestoreBorrowerRepository(this.userId);

  CollectionReference get _borrowersCollection => _firestore
      .collection('users')
      .doc(userId)
      .collection(DbConstants.borrowersTable);

  @override
  Future<Borrower> create({
    required String name,
    String? phone,
    String? email,
    String? notes,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();

    final borrower = Borrower(
      id: id,
      name: name,
      phone: phone,
      email: email,
      notes: notes,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _borrowersCollection.doc(id).set(borrower.toMap());
    return borrower;
  }

  @override
  Future<Borrower?> getById(String id) async {
    final doc = await _borrowersCollection.doc(id).get();
    if (!doc.exists) return null;
    return Borrower.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<Borrower>> getAll({bool includeDeleted = false}) async {
    Query query = _borrowersCollection.orderBy(DbConstants.borrowerName);

    if (!includeDeleted) {
      query = query.where(DbConstants.borrowerIsDeleted, isEqualTo: 0);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Borrower.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Borrower>> search(String query) async {
    // Firestore doesn't support native LIKE search efficiently.
    // For simple prefix search we can use:
    final snapshot = await _borrowersCollection
        .where(DbConstants.borrowerIsDeleted, isEqualTo: 0)
        .where(DbConstants.borrowerName, isGreaterThanOrEqualTo: query)
        .where(DbConstants.borrowerName, isLessThan: '${query}z')
        .orderBy(DbConstants.borrowerName)
        .get();

    return snapshot.docs
        .map((doc) => Borrower.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Borrower> update(Borrower borrower) async {
    final updatedBorrower = borrower.copyWith(updatedAt: DateTime.now());

    await _borrowersCollection.doc(borrower.id).update(updatedBorrower.toMap());

    return updatedBorrower;
  }

  @override
  Future<void> softDelete(String id) async {
    await _borrowersCollection.doc(id).update({
      DbConstants.borrowerIsDeleted: 1,
      DbConstants.borrowerUpdatedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> restore(String id) async {
    await _borrowersCollection.doc(id).update({
      DbConstants.borrowerIsDeleted: 0,
      DbConstants.borrowerUpdatedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<bool> hardDelete(String id) async {
    // Check for active loans (this would ideally be a transaction or cloud function)
    // For now, we'll just check client-side
    final loansSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(DbConstants.loansTable)
        .where(DbConstants.loanBorrowerId, isEqualTo: id)
        .limit(1)
        .get();

    if (loansSnapshot.docs.isNotEmpty) {
      return false;
    }

    await _borrowersCollection.doc(id).delete();
    return true;
  }

  @override
  Future<int> getCount({bool includeDeleted = false}) async {
    final snapshot =
        await (includeDeleted
                ? _borrowersCollection
                : _borrowersCollection.where(
                    DbConstants.borrowerIsDeleted,
                    isEqualTo: 0,
                  ))
            .count()
            .get();

    return snapshot.count ?? 0;
  }
}
