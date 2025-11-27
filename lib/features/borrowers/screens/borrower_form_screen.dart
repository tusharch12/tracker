import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/providers.dart';
import '../../../providers/borrower_provider.dart';

class BorrowerFormScreen extends ConsumerStatefulWidget {
  final String? borrowerId; // null for create, id for edit

  const BorrowerFormScreen({
    super.key,
    this.borrowerId,
  });

  @override
  ConsumerState<BorrowerFormScreen> createState() => _BorrowerFormScreenState();
}

class _BorrowerFormScreenState extends ConsumerState<BorrowerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.borrowerId != null;
    if (_isEditMode) {
      _loadBorrower();
    }
  }

  Future<void> _loadBorrower() async {
    final repo = ref.read(borrowerRepositoryProvider);
    final borrower = await repo.getById(widget.borrowerId!);
    
    if (borrower != null && mounted) {
      _nameController.text = borrower.name;
      _phoneController.text = borrower.phone ?? '';
      _emailController.text = borrower.email ?? '';
      _notesController.text = borrower.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveBorrower() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(borrowerRepositoryProvider);
      
      if (_isEditMode) {
        // Update existing borrower
        final existing = await repo.getById(widget.borrowerId!);
        if (existing != null) {
          final updated = existing.copyWith(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          );
          await repo.update(updated);
        }
      } else {
        // Create new borrower
        await repo.create(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      }

      // Refresh borrower list
      ref.invalidate(borrowersProvider);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Borrower updated successfully' : 'Borrower added successfully',
            ),
            backgroundColor: AppColors.pureBlack,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.overdue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Borrower' : 'Add Borrower',
          style: AppTextStyles.h1,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          children: [
            // Name Field
            Text(
              'NAME *',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter borrower name',
              ),
              validator: Validators.validateName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Phone Field
            Text(
              'PHONE',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Email Field
            Text(
              'EMAIL',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: AppDimensions.lg),

            // Notes Field
            Text(
              'NOTES',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add any additional notes',
              ),
              maxLines: 3,
              validator: Validators.validateNotes,
            ),
            const SizedBox(height: AppDimensions.xl),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveBorrower,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.pureWhite,
                      ),
                    )
                  : Text(_isEditMode ? 'Update Borrower' : 'Add Borrower'),
            ),
          ],
        ),
      ),
    );
  }
}
