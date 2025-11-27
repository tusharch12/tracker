import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../models/loan.dart';
import '../../../providers/loan_provider.dart';
import '../widgets/loan_card.dart';

class LoanListScreen extends ConsumerStatefulWidget {
  final String? borrowerId; // null for all loans, id for borrower-specific

  const LoanListScreen({
    super.key,
    this.borrowerId,
  });

  @override
  ConsumerState<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends ConsumerState<LoanListScreen> {
  LoanStatus? _filterStatus;

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Text(
                'Filter Loans',
                style: AppTextStyles.h2,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('All Loans'),
              trailing: _filterStatus == null ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _filterStatus = null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Active'),
              trailing: _filterStatus == LoanStatus.active ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _filterStatus = LoanStatus.active);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Completed'),
              trailing: _filterStatus == LoanStatus.completed ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _filterStatus = LoanStatus.completed);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Cancelled'),
              trailing: _filterStatus == LoanStatus.cancelled ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _filterStatus = LoanStatus.cancelled);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Defaulted'),
              trailing: _filterStatus == LoanStatus.defaulted ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _filterStatus = LoanStatus.defaulted);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loansAsync = widget.borrowerId != null
        ? ref.watch(loansByBorrowerProvider(widget.borrowerId!))
        : ref.watch(allLoansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.borrowerId != null ? 'Loans' : 'All Loans',
          style: AppTextStyles.h1,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _filterStatus == null ? Icons.filter_list : Icons.filter_list_alt,
              color: _filterStatus == null ? AppColors.pureBlack : Theme.of(context).primaryColor,
            ),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              if (widget.borrowerId != null) {
                ref.invalidate(loansByBorrowerProvider(widget.borrowerId!));
              } else {
                ref.invalidate(allLoansProvider);
              }
            },
          ),
        ],
      ),
      body: loansAsync.when(
        data: (loans) {
          // Apply filter
          final filteredLoans = _filterStatus != null
              ? loans.where((l) => l.status == _filterStatus).toList()
              : loans;

          if (filteredLoans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.paleGray,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    _filterStatus != null ? 'No ${_filterStatus!.name} loans' : 'No loans yet',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_filterStatus == null) ...[
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Add a loan to get started',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // Group loans by status for display if no filter is active
          // If filter is active, just show the list
          if (_filterStatus != null) {
            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.md),
              itemCount: filteredLoans.length,
              itemBuilder: (context, index) {
                final loan = filteredLoans[index];
                return LoanCard(
                  loan: loan,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/loans/detail',
                      arguments: loan.id,
                    );
                  },
                );
              },
            );
          }

          // Default grouped view
          final activeLoans = filteredLoans.where((l) => l.status == LoanStatus.active).toList();
          final completedLoans = filteredLoans.where((l) => l.status == LoanStatus.completed).toList();
          final cancelledLoans = filteredLoans.where((l) => l.status == LoanStatus.cancelled).toList();
          final defaultedLoans = filteredLoans.where((l) => l.status == LoanStatus.defaulted).toList();

          return ListView(
            padding: const EdgeInsets.all(AppDimensions.md),
            children: [
              // Active Loans
              if (activeLoans.isNotEmpty) ...[
                Text(
                  'ACTIVE LOANS (${activeLoans.length})',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppDimensions.sm),
                ...activeLoans.map((loan) => LoanCard(
                  loan: loan,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/loans/detail',
                      arguments: loan.id,
                    );
                  },
                )),
                const SizedBox(height: AppDimensions.lg),
              ],

              // Completed Loans
              if (completedLoans.isNotEmpty) ...[
                Text(
                  'COMPLETED LOANS (${completedLoans.length})',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppDimensions.sm),
                ...completedLoans.map((loan) => LoanCard(
                  loan: loan,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/loans/detail',
                      arguments: loan.id,
                    );
                  },
                )),
                const SizedBox(height: AppDimensions.lg),
              ],
              
              // Defaulted Loans
              if (defaultedLoans.isNotEmpty) ...[
                Text(
                  'DEFAULTED LOANS (${defaultedLoans.length})',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppDimensions.sm),
                ...defaultedLoans.map((loan) => LoanCard(
                  loan: loan,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/loans/detail',
                      arguments: loan.id,
                    );
                  },
                )),
                const SizedBox(height: AppDimensions.lg),
              ],

              // Cancelled Loans
              if (cancelledLoans.isNotEmpty) ...[
                Text(
                  'CANCELLED LOANS (${cancelledLoans.length})',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppDimensions.sm),
                ...cancelledLoans.map((loan) => LoanCard(
                  loan: loan,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/loans/detail',
                      arguments: loan.id,
                    );
                  },
                )),
              ],
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.pureBlack,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.overdue,
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Error loading loans',
                style: AppTextStyles.h3,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.borrowerId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/loans/form',
                  arguments: widget.borrowerId,
                );
              },
              backgroundColor: AppColors.pureBlack,
              foregroundColor: AppColors.pureWhite,
              icon: const Icon(Icons.add),
              label: const Text('Add Loan'),
            )
          : null,
    );
  }
}
