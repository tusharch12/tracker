import '../core/constants/db_constants.dart';

enum LoanStatus {
  active,
  completed,
  cancelled,
  defaulted;

  String get value {
    switch (this) {
      case LoanStatus.active:
        return DbConstants.statusActive;
      case LoanStatus.completed:
        return DbConstants.statusCompleted;
      case LoanStatus.cancelled:
        return DbConstants.statusCancelled;
      case LoanStatus.defaulted:
        return DbConstants.statusDefaulted;
    }
  }

  static LoanStatus fromString(String value) {
    switch (value) {
      case DbConstants.statusActive:
        return LoanStatus.active;
      case DbConstants.statusCompleted:
        return LoanStatus.completed;
      case DbConstants.statusCancelled:
        return LoanStatus.cancelled;
      case DbConstants.statusDefaulted:
        return LoanStatus.defaulted;
      default:
        return LoanStatus.active;
    }
  }
}

class Loan {
  final String id;
  final String borrowerId;
  final double principalAmount;
  final DateTime startDate;
  final double installmentAmount;
  final int installmentFrequency; // in months: 1=monthly, 3=quarterly, etc.
  final int? totalInstallments;
  final DateTime? expectedEndDate;
  final LoanStatus status;
  final String? notes;
  final int extraInstallments;
  final double profitAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Loan({
    required this.id,
    required this.borrowerId,
    required this.principalAmount,
    required this.startDate,
    required this.installmentAmount,
    this.installmentFrequency = 1, // default to monthly
    this.totalInstallments,
    this.expectedEndDate,
    this.status = LoanStatus.active,
    this.notes,
    this.extraInstallments = 0,
    this.profitAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      DbConstants.loanId: id,
      DbConstants.loanBorrowerId: borrowerId,
      DbConstants.loanPrincipalAmount: principalAmount,
      DbConstants.loanStartDate: startDate.millisecondsSinceEpoch,
      DbConstants.loanInstallmentAmount: installmentAmount,
      DbConstants.loanInstallmentFrequency: installmentFrequency,
      DbConstants.loanTotalInstallments: totalInstallments,
      DbConstants.loanExpectedEndDate: expectedEndDate?.millisecondsSinceEpoch,
      DbConstants.loanStatus: status.value,
      DbConstants.loanNotes: notes,
      DbConstants.loanExtraInstallments: extraInstallments,
      DbConstants.loanProfitAmount: profitAmount,
      DbConstants.loanCreatedAt: createdAt.millisecondsSinceEpoch,
      DbConstants.loanUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map (database)
  factory Loan.fromMap(Map<String, dynamic> map) {
    DateTime toDateTime(dynamic value) {
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value.runtimeType.toString() == 'Timestamp') {
        return (value as dynamic).toDate();
      }
      return DateTime.now();
    }

    return Loan(
      id: map[DbConstants.loanId] as String,
      borrowerId: map[DbConstants.loanBorrowerId] as String,
      principalAmount: (map[DbConstants.loanPrincipalAmount] as num).toDouble(),
      startDate: toDateTime(map[DbConstants.loanStartDate]),
      installmentAmount: (map[DbConstants.loanInstallmentAmount] as num)
          .toDouble(),
      installmentFrequency:
          map[DbConstants.loanInstallmentFrequency] as int? ?? 1,
      totalInstallments: map[DbConstants.loanTotalInstallments] as int?,
      expectedEndDate: map[DbConstants.loanExpectedEndDate] != null
          ? toDateTime(map[DbConstants.loanExpectedEndDate])
          : null,
      status: LoanStatus.fromString(map[DbConstants.loanStatus] as String),
      notes: map[DbConstants.loanNotes] as String?,
      extraInstallments: map[DbConstants.loanExtraInstallments] as int? ?? 0,
      profitAmount:
          (map[DbConstants.loanProfitAmount] as num?)?.toDouble() ?? 0.0,
      createdAt: toDateTime(map[DbConstants.loanCreatedAt]),
      updatedAt: toDateTime(map[DbConstants.loanUpdatedAt]),
    );
  }

  // Copy with method for updates
  Loan copyWith({
    String? id,
    String? borrowerId,
    double? principalAmount,
    DateTime? startDate,
    double? installmentAmount,
    int? installmentFrequency,
    int? totalInstallments,
    DateTime? expectedEndDate,
    LoanStatus? status,
    String? notes,
    int? extraInstallments,
    double? profitAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      borrowerId: borrowerId ?? this.borrowerId,
      principalAmount: principalAmount ?? this.principalAmount,
      startDate: startDate ?? this.startDate,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      installmentFrequency: installmentFrequency ?? this.installmentFrequency,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      extraInstallments: extraInstallments ?? this.extraInstallments,
      profitAmount: profitAmount ?? this.profitAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Loan(id: $id, borrowerId: $borrowerId, principal: $principalAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Loan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
