import '../core/constants/db_constants.dart';

class Borrower {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Borrower({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.notes,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      DbConstants.borrowerId: id,
      DbConstants.borrowerName: name,
      DbConstants.borrowerPhone: phone,
      DbConstants.borrowerEmail: email,
      DbConstants.borrowerNotes: notes,
      DbConstants.borrowerIsDeleted: isDeleted ? 1 : 0,
      DbConstants.borrowerCreatedAt: createdAt.millisecondsSinceEpoch,
      DbConstants.borrowerUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map (database)
  factory Borrower.fromMap(Map<String, dynamic> map) {
    DateTime toDateTime(dynamic value) {
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value.runtimeType.toString() == 'Timestamp') {
        // Avoid direct dependency on cloud_firestore in model if possible,
        // or just use dynamic access if we don't want to import the package.
        // But importing is safer. Let's import cloud_firestore.
        return (value as dynamic).toDate();
      }
      return DateTime.now(); // Fallback
    }

    return Borrower(
      id: map[DbConstants.borrowerId] as String,
      name: map[DbConstants.borrowerName] as String,
      phone: map[DbConstants.borrowerPhone] as String?,
      email: map[DbConstants.borrowerEmail] as String?,
      notes: map[DbConstants.borrowerNotes] as String?,
      isDeleted: (map[DbConstants.borrowerIsDeleted] is int)
          ? (map[DbConstants.borrowerIsDeleted] as int) == 1
          : map[DbConstants.borrowerIsDeleted] as bool,
      createdAt: toDateTime(map[DbConstants.borrowerCreatedAt]),
      updatedAt: toDateTime(map[DbConstants.borrowerUpdatedAt]),
    );
  }

  // Copy with method for updates
  Borrower copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Borrower(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Borrower(id: $id, name: $name, phone: $phone, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Borrower && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
