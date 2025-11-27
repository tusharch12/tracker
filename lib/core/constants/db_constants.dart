// Database constants
class DbConstants {
  // Database
  static const String databaseName = 'tracker.db';
  static const int databaseVersion = 2;

  // Tables
  static const String borrowersTable = 'borrowers';
  static const String loansTable = 'loans';
  static const String paymentsTable = 'payments';

  // Borrowers Table Columns
  static const String borrowerId = 'id';
  static const String borrowerName = 'name';
  static const String borrowerPhone = 'phone';
  static const String borrowerEmail = 'email';
  static const String borrowerNotes = 'notes';
  static const String borrowerIsDeleted = 'is_deleted';
  static const String borrowerCreatedAt = 'created_at';
  static const String borrowerUpdatedAt = 'updated_at';

  // Loans Table Columns
  static const String loanId = 'id';
  static const String loanBorrowerId = 'borrower_id';
  static const String loanPrincipalAmount = 'principal_amount';
  static const String loanStartDate = 'start_date';
  static const String loanInstallmentAmount = 'installment_amount';
  static const String loanInstallmentFrequency = 'installment_frequency';
  static const String loanTotalInstallments = 'total_installments';
  static const String loanExpectedEndDate = 'expected_end_date';
  static const String loanStatus = 'status';
  static const String loanNotes = 'notes';
  static const String loanCreatedAt = 'created_at';
  static const String loanUpdatedAt = 'updated_at';
  static const String loanExtraInstallments = 'extra_installments';
  static const String loanProfitAmount = 'profit_amount';

  // Payments Table Columns
  static const String paymentId = 'id';
  static const String paymentLoanId = 'loan_id';
  static const String paymentAmount = 'amount';
  static const String paymentDate = 'payment_date';
  static const String paymentMethod = 'payment_method';
  static const String paymentNotes = 'notes';
  static const String paymentCreatedAt = 'created_at';
  static const String paymentUpdatedAt = 'updated_at';

  // Loan Status Values
  static const String statusActive = 'active';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusDefaulted = 'defaulted';
}
