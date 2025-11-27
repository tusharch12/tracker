import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/db_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.databaseName);

    return await openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create Borrowers Table
    await db.execute('''
      CREATE TABLE ${DbConstants.borrowersTable} (
        ${DbConstants.borrowerId} TEXT PRIMARY KEY,
        ${DbConstants.borrowerName} TEXT NOT NULL,
        ${DbConstants.borrowerPhone} TEXT,
        ${DbConstants.borrowerEmail} TEXT,
        ${DbConstants.borrowerNotes} TEXT,
        ${DbConstants.borrowerIsDeleted} INTEGER DEFAULT 0,
        ${DbConstants.borrowerCreatedAt} INTEGER NOT NULL,
        ${DbConstants.borrowerUpdatedAt} INTEGER NOT NULL
      )
    ''');

    // Create Loans Table
    await db.execute('''
      CREATE TABLE ${DbConstants.loansTable} (
        ${DbConstants.loanId} TEXT PRIMARY KEY,
        ${DbConstants.loanBorrowerId} TEXT NOT NULL,
        ${DbConstants.loanPrincipalAmount} REAL NOT NULL,
        ${DbConstants.loanStartDate} INTEGER NOT NULL,
        ${DbConstants.loanInstallmentAmount} REAL NOT NULL,
        ${DbConstants.loanInstallmentFrequency} INTEGER DEFAULT 1,
        ${DbConstants.loanTotalInstallments} INTEGER,
        ${DbConstants.loanExpectedEndDate} INTEGER,
        ${DbConstants.loanStatus} TEXT NOT NULL,
        ${DbConstants.loanNotes} TEXT,
        ${DbConstants.loanExtraInstallments} INTEGER DEFAULT 0,
        ${DbConstants.loanProfitAmount} REAL DEFAULT 0.0,
        ${DbConstants.loanCreatedAt} INTEGER NOT NULL,
        ${DbConstants.loanUpdatedAt} INTEGER NOT NULL,
        FOREIGN KEY (${DbConstants.loanBorrowerId}) 
          REFERENCES ${DbConstants.borrowersTable}(${DbConstants.borrowerId})
      )
    ''');

    // Create Payments Table
    await db.execute('''
      CREATE TABLE ${DbConstants.paymentsTable} (
        ${DbConstants.paymentId} TEXT PRIMARY KEY,
        ${DbConstants.paymentLoanId} TEXT NOT NULL,
        ${DbConstants.paymentAmount} REAL NOT NULL,
        ${DbConstants.paymentDate} INTEGER NOT NULL,
        ${DbConstants.paymentMethod} TEXT,
        ${DbConstants.paymentNotes} TEXT,
        ${DbConstants.paymentCreatedAt} INTEGER NOT NULL,
        ${DbConstants.paymentUpdatedAt} INTEGER NOT NULL,
        FOREIGN KEY (${DbConstants.paymentLoanId}) 
          REFERENCES ${DbConstants.loansTable}(${DbConstants.loanId})
      )
    ''');

    // Create Indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_loans_borrower_id 
      ON ${DbConstants.loansTable}(${DbConstants.loanBorrowerId})
    ''');

    await db.execute('''
      CREATE INDEX idx_payments_loan_id 
      ON ${DbConstants.paymentsTable}(${DbConstants.paymentLoanId})
    ''');

    await db.execute('''
      CREATE INDEX idx_borrowers_is_deleted 
      ON ${DbConstants.borrowersTable}(${DbConstants.borrowerIsDeleted})
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here in future versions
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${DbConstants.loansTable} ADD COLUMN ${DbConstants.loanExtraInstallments} INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE ${DbConstants.loansTable} ADD COLUMN ${DbConstants.loanProfitAmount} REAL DEFAULT 0.0',
      );
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
