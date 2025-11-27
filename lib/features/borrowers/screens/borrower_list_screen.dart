import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../providers/borrower_provider.dart';
import '../widgets/borrower_card.dart';

class BorrowerListScreen extends ConsumerWidget {
  const BorrowerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borrowersAsync = ref.watch(filteredBorrowersProvider);
    final searchQuery = ref.watch(borrowerSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Borrowers', style: AppTextStyles.h1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () {
              ref.invalidate(borrowersProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: TextField(
              onChanged: (value) {
                ref.read(borrowerSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          ref.read(borrowerSearchQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Borrowers List
          Expanded(
            child: borrowersAsync.when(
              data: (borrowers) {
                if (borrowers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isNotEmpty
                              ? Icons.search_off_outlined
                              : Icons.person_add_outlined,
                          size: 64,
                          color: AppColors.paleGray,
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'No borrowers found'
                              : 'No borrowers yet',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Try a different search term'
                              : 'Add your first borrower to get started',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                  itemCount: borrowers.length,
                  itemBuilder: (context, index) {
                    print(borrowers[index]);
                    return BorrowerCard(
                      borrower: borrowers[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/borrowers/detail',
                          arguments: borrowers[index].id,
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.pureBlack),
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
                    Text('Error loading borrowers', style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      error.toString(),
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/borrowers/form');
        },
        backgroundColor: AppColors.pureBlack,
        foregroundColor: AppColors.pureWhite,
        icon: const Icon(Icons.add),
        label: const Text('Add Borrower'),
      ),
    );
  }
}
