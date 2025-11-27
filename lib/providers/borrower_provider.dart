import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/borrower.dart';
import 'providers.dart';

// All borrowers provider
final borrowersProvider = FutureProvider<List<Borrower>>((ref) async {
  final repo = ref.watch(borrowerRepositoryProvider);
  return await repo.getAll();
});

// Search query state
final borrowerSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered borrowers based on search
final filteredBorrowersProvider = FutureProvider<List<Borrower>>((ref) async {
  final borrowers = await ref.watch(borrowersProvider.future);
  final query = ref.watch(borrowerSearchQueryProvider);
  
  if (query.isEmpty) {
    return borrowers;
  }
  
  return borrowers.where((b) => 
    b.name.toLowerCase().contains(query.toLowerCase()) ||
    (b.phone?.contains(query) ?? false) ||
    (b.email?.toLowerCase().contains(query.toLowerCase()) ?? false)
  ).toList();
});

// Single borrower provider
final borrowerProvider = FutureProvider.family<Borrower?, String>((ref, id) async {
  final repo = ref.watch(borrowerRepositoryProvider);
  return await repo.getById(id);
});

// Refresh borrowers
final refreshBorrowersProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(borrowersProvider);
  };
});
