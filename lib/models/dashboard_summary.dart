class DashboardSummary {
  final double totalLent;
  final double totalReceived;
  final double totalRemaining;
  final double dueThisMonth;
  final int overdueLoansCount;
  final int activeLoansCount;
  final int completedLoansCount;
  final int totalBorrowersCount;

  DashboardSummary({
    required this.totalLent,
    required this.totalReceived,
    required this.totalRemaining,
    required this.dueThisMonth,
    required this.overdueLoansCount,
    required this.activeLoansCount,
    required this.completedLoansCount,
    required this.totalBorrowersCount,
  });

  // Create empty summary
  factory DashboardSummary.empty() {
    return DashboardSummary(
      totalLent: 0,
      totalReceived: 0,
      totalRemaining: 0,
      dueThisMonth: 0,
      overdueLoansCount: 0,
      activeLoansCount: 0,
      completedLoansCount: 0,
      totalBorrowersCount: 0,
    );
  }

  // Copy with method
  DashboardSummary copyWith({
    double? totalLent,
    double? totalReceived,
    double? totalRemaining,
    double? dueThisMonth,
    int? overdueLoansCount,
    int? activeLoansCount,
    int? completedLoansCount,
    int? totalBorrowersCount,
  }) {
    return DashboardSummary(
      totalLent: totalLent ?? this.totalLent,
      totalReceived: totalReceived ?? this.totalReceived,
      totalRemaining: totalRemaining ?? this.totalRemaining,
      dueThisMonth: dueThisMonth ?? this.dueThisMonth,
      overdueLoansCount: overdueLoansCount ?? this.overdueLoansCount,
      activeLoansCount: activeLoansCount ?? this.activeLoansCount,
      completedLoansCount: completedLoansCount ?? this.completedLoansCount,
      totalBorrowersCount: totalBorrowersCount ?? this.totalBorrowersCount,
    );
  }

  @override
  String toString() {
    return 'DashboardSummary(totalLent: $totalLent, totalReceived: $totalReceived, totalRemaining: $totalRemaining)';
  }
}
