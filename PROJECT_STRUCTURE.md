# Money Lending Tracker - Flutter Project Structure

## Architecture Overview

This app follows **Clean Architecture** with **Feature-First** organization, using:
- **SQLite** for local database
- **Riverpod** for state management
- **Repository pattern** for data access
- **MVVM** pattern for UI logic

---

## Project Structure

```
tracker/
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── core/                              # Core utilities & shared code
│   │   ├── constants/
│   │   │   ├── app_constants.dart         # App-wide constants
│   │   │   ├── db_constants.dart          # Database table/column names
│   │   │   └── route_constants.dart       # Route names
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # Black & white theme
│   │   │   ├── app_colors.dart            # Color palette
│   │   │   ├── app_text_styles.dart       # Typography system
│   │   │   └── app_dimensions.dart        # Spacing, sizes
│   │   │
│   │   ├── utils/
│   │   │   ├── date_utils.dart            # Date calculations
│   │   │   ├── currency_formatter.dart    # Money formatting
│   │   │   ├── validators.dart            # Input validation
│   │   │   └── calculation_helpers.dart   # Loan calculations
│   │   │
│   │   ├── database/
│   │   │   ├── database_helper.dart       # SQLite setup
│   │   │   ├── migrations.dart            # DB migrations
│   │   │   └── tables.dart                # Table schemas
│   │   │
│   │   ├── widgets/                       # Shared widgets
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── custom_card.dart
│   │   │   ├── status_badge.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_widget.dart
│   │   │
│   │   └── extensions/
│   │       ├── date_extensions.dart
│   │       ├── string_extensions.dart
│   │       └── number_extensions.dart
│   │
│   ├── models/                            # Data models
│   │   ├── borrower.dart
│   │   ├── loan.dart
│   │   ├── payment.dart
│   │   └── dashboard_summary.dart
│   │
│   ├── repositories/                      # Data access layer
│   │   ├── borrower_repository.dart
│   │   ├── loan_repository.dart
│   │   └── payment_repository.dart
│   │
│   ├── services/                          # Business logic services
│   │   ├── calculation_service.dart       # Loan calculations
│   │   ├── validation_service.dart        # Business validation
│   │   └── security_service.dart          # PIN lock
│   │
│   ├── providers/                         # State management
│   │   ├── borrower_provider.dart
│   │   ├── loan_provider.dart
│   │   ├── payment_provider.dart
│   │   └── dashboard_provider.dart
│   │
│   ├── features/                          # Feature modules
│   │   │
│   │   ├── dashboard/
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── summary_card.dart
│   │   │   │   ├── metric_card.dart
│   │   │   │   ├── overdue_list.dart
│   │   │   │   └── quick_actions.dart
│   │   │   └── viewmodels/
│   │   │       └── dashboard_viewmodel.dart
│   │   │
│   │   ├── borrowers/
│   │   │   ├── screens/
│   │   │   │   ├── borrower_list_screen.dart
│   │   │   │   ├── borrower_detail_screen.dart
│   │   │   │   └── borrower_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── borrower_card.dart
│   │   │   │   ├── borrower_search_bar.dart
│   │   │   │   └── borrower_summary.dart
│   │   │   └── viewmodels/
│   │   │       └── borrower_viewmodel.dart
│   │   │
│   │   ├── loans/
│   │   │   ├── screens/
│   │   │   │   ├── loan_list_screen.dart
│   │   │   │   ├── loan_detail_screen.dart
│   │   │   │   └── loan_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── loan_card.dart
│   │   │   │   ├── loan_status_badge.dart
│   │   │   │   ├── loan_timeline.dart
│   │   │   │   └── installment_schedule.dart
│   │   │   └── viewmodels/
│   │   │       └── loan_viewmodel.dart
│   │   │
│   │   ├── payments/
│   │   │   ├── screens/
│   │   │   │   ├── payment_list_screen.dart
│   │   │   │   └── payment_form_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── payment_card.dart
│   │   │   │   ├── payment_history.dart
│   │   │   │   └── payment_summary.dart
│   │   │   └── viewmodels/
│   │   │       └── payment_viewmodel.dart
│   │   │
│   │   └── settings/
│   │       ├── screens/
│   │       │   ├── settings_screen.dart
│   │       │   └── pin_setup_screen.dart
│   │       └── widgets/
│   │           └── settings_tile.dart
│   │
│   └── routes/
│       └── app_router.dart                # Navigation setup
│
├── assets/                                # Static assets
│   ├── fonts/
│   │   ├── Inter/
│   │   └── JetBrainsMono/
│   └── icons/
│       └── app_icon.png
│
├── test/                                  # Unit tests
│   ├── models/
│   ├── repositories/
│   ├── services/
│   └── utils/
│
├── integration_test/                      # Integration tests
│   └── app_test.dart
│
├── pubspec.yaml                           # Dependencies
├── analysis_options.yaml                  # Linting rules
└── README.md
```

---

## File Count Estimation

### Core Layer (~15 files)
- Constants: 3 files
- Theme: 4 files
- Utils: 4 files
- Database: 3 files
- Extensions: 3 files

### Shared Widgets (~7 files)
- Reusable UI components

### Models (~4 files)
- Data classes

### Repositories (~3 files)
- Data access

### Services (~3 files)
- Business logic

### Providers (~4 files)
- State management

### Dashboard Feature (~7 files)
- 1 screen
- 4 widgets
- 1 viewmodel
- 1 feature file

### Borrowers Feature (~7 files)
- 3 screens
- 3 widgets
- 1 viewmodel

### Loans Feature (~8 files)
- 3 screens
- 4 widgets
- 1 viewmodel

### Payments Feature (~6 files)
- 2 screens
- 3 widgets
- 1 viewmodel

### Settings Feature (~4 files)
- 2 screens
- 1 widget
- 1 feature file

### Routes & Main (~2 files)
- Router and main entry

---

## **Total Estimated Files: ~70 Dart files**

---

## Key Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Database
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # UI
  google_fonts: ^6.1.0
  
  # Utilities
  intl: ^0.18.1                 # Date/currency formatting
  uuid: ^4.2.1                  # Unique IDs
  
  # Security
  flutter_secure_storage: ^9.0.0  # PIN storage
  local_auth: ^2.1.7            # Biometric auth (future)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  integration_test:
    sdk: flutter
```

---

## Database Schema (SQLite)

### Tables

**borrowers**
```sql
CREATE TABLE borrowers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  notes TEXT,
  is_deleted INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**loans**
```sql
CREATE TABLE loans (
  id TEXT PRIMARY KEY,
  borrower_id TEXT NOT NULL,
  principal_amount REAL NOT NULL,
  start_date INTEGER NOT NULL,
  installment_amount REAL NOT NULL,
  total_installments INTEGER,
  expected_end_date INTEGER,
  status TEXT NOT NULL,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (borrower_id) REFERENCES borrowers(id)
);
```

**payments**
```sql
CREATE TABLE payments (
  id TEXT PRIMARY KEY,
  loan_id TEXT NOT NULL,
  amount REAL NOT NULL,
  payment_date INTEGER NOT NULL,
  payment_method TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (loan_id) REFERENCES loans(id)
);
```

---

## Development Phases

### Phase 1: Foundation (Week 1)
- Set up project structure
- Configure SQLite database
- Create models and database helper
- Implement theme system

### Phase 2: Core Features (Week 2-3)
- Borrower CRUD
- Loan CRUD
- Payment CRUD
- Calculation services

### Phase 3: UI Development (Week 4-5)
- Dashboard screen
- Borrower management screens
- Loan management screens
- Payment screens

### Phase 4: Polish & Testing (Week 6)
- Edge case handling
- Performance optimization
- Testing
- PIN lock implementation

---

## Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Private members**: `_leadingUnderscore`

---

## Code Organization Principles

1. **Feature-First**: Group by feature, not by type
2. **Single Responsibility**: Each file has one clear purpose
3. **Dependency Injection**: Use providers for dependencies
4. **Separation of Concerns**: UI ↔ ViewModel ↔ Repository ↔ Database
5. **Reusability**: Shared widgets in core/widgets
6. **Testability**: Business logic separate from UI

---

This structure supports scalability, maintainability, and follows Flutter best practices while keeping the codebase organized and easy to navigate.
