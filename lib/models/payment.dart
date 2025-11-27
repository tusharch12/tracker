import '../core/constants/db_constants.dart';

class Payment {
  final String id;
  final String loanId;
  final double amount;
  final DateTime paymentDate;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      DbConstants.paymentId: id,
      DbConstants.paymentLoanId: loanId,
      DbConstants.paymentAmount: amount,
      DbConstants.paymentDate: paymentDate.millisecondsSinceEpoch,
      DbConstants.paymentMethod: paymentMethod,
      DbConstants.paymentNotes: notes,
      DbConstants.paymentCreatedAt: createdAt.millisecondsSinceEpoch,
      DbConstants.paymentUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map (database)
  factory Payment.fromMap(Map<String, dynamic> map) {
    DateTime toDateTime(dynamic value) {
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value.runtimeType.toString() == 'Timestamp') {
        return (value as dynamic).toDate();
      }
      return DateTime.now();
    }

    return Payment(
      id: map[DbConstants.paymentId] as String,
      loanId: map[DbConstants.paymentLoanId] as String,
      amount: (map[DbConstants.paymentAmount] as num).toDouble(),
      paymentDate: toDateTime(map[DbConstants.paymentDate]),
      paymentMethod: map[DbConstants.paymentMethod] as String?,
      notes: map[DbConstants.paymentNotes] as String?,
      createdAt: toDateTime(map[DbConstants.paymentCreatedAt]),
      updatedAt: toDateTime(map[DbConstants.paymentUpdatedAt]),
    );
  }

  // Copy with method for updates
  Payment copyWith({
    String? id,
    String? loanId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, loanId: $loanId, amount: $amount, date: $paymentDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
