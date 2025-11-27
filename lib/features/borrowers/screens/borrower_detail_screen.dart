import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/borrower_provider.dart';
import '../../../providers/loan_provider.dart';
import '../../../models/loan.dart';
import '../../loans/widgets/loan_card.dart';

class BorrowerDetailScreen extends ConsumerWidget {
  final String borrowerId;

  const BorrowerDetailScreen({
    super.key,
    required this.borrowerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowerAsync = ref.watch(borrowerProvider(borrowerId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: borrowerAsync.when(
          data: (borrower) {
            if (borrower == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 64,
                      color: AppColors.paleGray,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'Borrower not found',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    floating: true,
                    backgroundColor: AppColors.pureWhite,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/borrowers/form',
                            arguments: borrowerId,
                          );
                          if (result == true) {
                            ref.invalidate(borrowerProvider(borrowerId));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          _showOptionsMenu(context, ref);
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40), // Adjust for status bar
                            Container(
                              width: AppDimensions.avatarLarge,
                              height: AppDimensions.avatarLarge,
                              decoration: BoxDecoration(
                                color: AppColors.pureBlack,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(borrower.name),
                                  style: AppTextStyles.display.copyWith(
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.md),
                            Text(
                              borrower.name,
                              style: AppTextStyles.display,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottom: const TabBar(
                      labelColor: AppColors.pureBlack,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.pureBlack,
                      tabs: [
                        Tab(text: 'Details'),
                        Tab(text: 'Loans'),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _buildDetailsTab(borrower),
                  _buildLoansTab(ref),
                ],
              ),
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
                  'Error loading borrower',
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/loans/form',
              arguments: borrowerId,
            );
          },
          backgroundColor: AppColors.pureBlack,
          foregroundColor: AppColors.pureWhite,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(dynamic borrower) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      children: [
        // Contact Information
        _buildSection(
          'Contact Information',
          [
            if (borrower.phone != null)
              _buildInfoRow(
                Icons.phone_outlined,
                'Phone',
                borrower.phone!,
              ),
            if (borrower.email != null)
              _buildInfoRow(
                Icons.email_outlined,
                'Email',
                borrower.email!,
              ),
            if (borrower.phone == null && borrower.email == null)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Text(
                  'No contact information',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.lg),

        // Notes
        if (borrower.notes != null) ...[
          _buildSection(
            'Notes',
            [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Text(
                  borrower.notes!,
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
        ],

        // Loan Summary (placeholder)
        _buildSection(
          'Loan Summary',
          [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                children: [
                  _buildSummaryRow('Total Borrowed', '₹0'),
                  const SizedBox(height: AppDimensions.sm),
                  _buildSummaryRow('Total Paid', '₹0'),
                  const SizedBox(height: AppDimensions.sm),
                  _buildSummaryRow('Remaining', '₹0'),
                  const SizedBox(height: AppDimensions.sm),
                  const Divider(),
                  const SizedBox(height: AppDimensions.sm),
                  _buildSummaryRow('Active Loans', '0'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildLoansTab(WidgetRef ref) {
    final loansAsync = ref.watch(loansByBorrowerProvider(borrowerId));

    return loansAsync.when(
      data: (loans) {
        if (loans.isEmpty) {
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
                  'No loans yet',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.md),
          itemCount: loans.length + 1, // +1 for FAB space
          itemBuilder: (context, index) {
            if (index == loans.length) {
              return const SizedBox(height: 80); // Space for FAB
            }
            final loan = loans[index];
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
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.pureBlack,
        ),
      ),
      error: (error, stack) => Center(
        child: Text('Error loading loans: $error'),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Text(
              title,
              style: AppTextStyles.h3,
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  value,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.h3,
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.overdue),
              title: Text(
                'Delete Borrower',
                style: AppTextStyles.body.copyWith(color: AppColors.overdue),
              ),
              onTap: () async {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Borrower'),
        content: const Text(
          'Are you sure you want to delete this borrower? '
          'This action cannot be undone if there are no active loans.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.overdue,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: Implement delete with validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete functionality will be implemented with validation'),
        ),
      );
    }
  }
}
