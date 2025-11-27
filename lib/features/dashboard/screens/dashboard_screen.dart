import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/dashboard_provider.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Money Tracker',
          style: AppTextStyles.h1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.invalidate(dashboardSummaryProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: dashboardAsync.when(
          data: (summary) => _buildDashboard(context, summary),
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
                  'Error loading dashboard',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  error.toString(),
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.lg),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(dashboardSummaryProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add borrower
          Navigator.pushNamed(context, '/borrowers/form');
        },
        backgroundColor: AppColors.pureBlack,
        foregroundColor: AppColors.pureWhite,
        icon: const Icon(Icons.add),
        label: const Text('Add Borrower'),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, dynamic summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Dashboard',
            style: AppTextStyles.display,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Overview of all your loans and payments',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // Summary Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.md,
            crossAxisSpacing: AppDimensions.md,
            childAspectRatio: 1.2,
            children: [
              SummaryCard(
                title: 'Total Lent',
                amount: summary.totalLent,
                icon: Icons.arrow_upward,
              ),
              SummaryCard(
                title: 'Total Received',
                amount: summary.totalReceived,
                icon: Icons.arrow_downward,
              ),
              SummaryCard(
                title: 'Remaining',
                amount: summary.totalRemaining,
                icon: Icons.account_balance_wallet_outlined,
              ),
              SummaryCard(
                title: 'Due This Month',
                amount: summary.dueThisMonth,
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Loans',
                  '${summary.activeLoansCount}',
                  AppColors.pureBlack,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildStatCard(
                  'Overdue',
                  '${summary.overdueLoansCount}',
                  summary.overdueLoansCount > 0
                      ? AppColors.overdue
                      : AppColors.pureBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  '${summary.completedLoansCount}',
                  AppColors.mediumGray,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildStatCard(
                  'Borrowers',
                  '${summary.totalBorrowersCount}',
                  AppColors.pureBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),

    
          const SizedBox(height: AppDimensions.md),

      

          // Empty state if no data
          if (summary.totalBorrowersCount == 0) ...[
            const SizedBox(height: AppDimensions.xl),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.xl),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AppColors.paleGray,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'No borrowers yet',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Start by adding a borrower using the button below',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
