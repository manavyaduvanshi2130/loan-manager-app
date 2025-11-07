import 'dart:async';
import 'package:flutter/foundation.dart'; // Import for debugPrint and kIsWeb
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/customer_model.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'loan_management.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 6, // Increment database version to trigger upgrade
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create customers table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        address TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create loans table
    await db.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        principal_amount REAL NOT NULL,
        interest_rate REAL NOT NULL,
        tenure_months INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        outstanding_amount REAL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Create payments table
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (loan_id) REFERENCES loans (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Original migration logic for version 1 to 2
      // This block attempts to rename 'createdAt' to 'created_at' and 'updatedAt' to 'updated_at'.
      // Added try-catch blocks to handle cases where the old camelCase columns might not exist.
      try {
        await db.execute(
          'ALTER TABLE customers ADD COLUMN created_at_temp TEXT',
        );
        await db.execute('UPDATE customers SET created_at_temp = createdAt');
        await db.execute('ALTER TABLE customers DROP COLUMN createdAt');
        await db.execute(
          'ALTER TABLE customers RENAME COLUMN created_at_temp TO created_at',
        );
      } catch (e) {
        debugPrint('Error migrating createdAt column from old schema: $e');
        // If 'createdAt' (camelCase) didn't exist, ensure 'created_at' (snake_case) is present.
        // This will be handled more robustly in the oldVersion < 3 block.
      }

      try {
        await db.execute(
          'ALTER TABLE customers ADD COLUMN updated_at_temp TEXT',
        );
        await db.execute('UPDATE customers SET updated_at_temp = updatedAt');
        await db.execute('ALTER TABLE customers DROP COLUMN updatedAt');
        await db.execute(
          'ALTER TABLE customers RENAME COLUMN updated_at_temp TO updated_at',
        );
      } catch (e) {
        debugPrint('Error migrating updatedAt column from old schema: $e');
        // If 'updatedAt' (camelCase) didn't exist, ensure 'updated_at' (snake_case) is present.
        // This will be handled more robustly in the oldVersion < 3 block.
      }
    }

    if (oldVersion < 3) {
      // Ensure 'created_at' and 'updated_at' columns exist for version 3.
      // This handles cases where previous migrations might have failed or were skipped,
      // or if the database was created with an older schema that completely lacked these.
      var tableInfo = await db.rawQuery("PRAGMA table_info(customers)");
      var columnNames = tableInfo.map((e) => e['name']).toList();

      if (!columnNames.contains('created_at')) {
        await db.execute(
          'ALTER TABLE customers ADD COLUMN created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP',
        );
      }
      if (!columnNames.contains('updated_at')) {
        await db.execute(
          'ALTER TABLE customers ADD COLUMN updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP',
        );
      }

      // Add customer_id to loans table if it doesn't exist
      var loanTableInfo = await db.rawQuery("PRAGMA table_info(loans)");
      var loanColumnNames = loanTableInfo.map((e) => e['name']).toList();

      if (!loanColumnNames.contains('customer_id')) {
        // If customer_id doesn't exist, check for old camelCase customerId
        if (loanColumnNames.contains('customerId')) {
          // If old camelCase column exists, rename it
          await db.execute(
            'ALTER TABLE loans ADD COLUMN customer_id_temp INTEGER',
          );
          await db.execute('UPDATE loans SET customer_id_temp = customerId');
          await db.execute('ALTER TABLE loans DROP COLUMN customerId');
          await db.execute(
            'ALTER TABLE loans RENAME COLUMN customer_id_temp TO customer_id',
          );
          debugPrint('Renamed customerId to customer_id in loans table.');
        } else {
          // If neither exists, add new customer_id column
          await db.execute(
            'ALTER TABLE loans ADD COLUMN customer_id INTEGER NOT NULL DEFAULT 0',
          ); // Default value might need adjustment
          debugPrint('Added customer_id column to loans table.');
        }
      }
    }

    if (oldVersion < 6) {
      // Migration for version 6: Ensure loans table has correct snake_case columns
      var loanTableInfo = await db.rawQuery("PRAGMA table_info(loans)");
      var loanColumnNames = loanTableInfo.map((e) => e['name']).toList();

      // Ensure customer_id exists and is snake_case
      if (!loanColumnNames.contains('customer_id')) {
        if (loanColumnNames.contains('customerId')) {
          // If old camelCase column exists, rename it
          await db.execute('ALTER TABLE loans ADD COLUMN customer_id_temp INTEGER');
          await db.execute('UPDATE loans SET customer_id_temp = customerId');
          await db.execute('ALTER TABLE loans DROP COLUMN customerId');
          await db.execute('ALTER TABLE loans RENAME COLUMN customer_id_temp TO customer_id');
          debugPrint('Renamed customerId to customer_id in loans table (v6 migration).');
        } else {
          // If neither exists, add new customer_id column
          await db.execute('ALTER TABLE loans ADD COLUMN customer_id INTEGER NOT NULL DEFAULT 0');
          debugPrint('Added customer_id column to loans table (v6 migration).');
        }
      }

      // Ensure created_at exists and is snake_case
      if (!loanColumnNames.contains('created_at')) {
        if (loanColumnNames.contains('createdAt')) {
          await db.execute('ALTER TABLE loans ADD COLUMN created_at_temp TEXT');
          await db.execute('UPDATE loans SET created_at_temp = createdAt');
          await db.execute('ALTER TABLE loans DROP COLUMN createdAt');
          await db.execute('ALTER TABLE loans RENAME COLUMN created_at_temp TO created_at');
          debugPrint('Renamed createdAt to created_at in loans table (v6 migration).');
        } else {
          await db.execute('ALTER TABLE loans ADD COLUMN created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP');
          debugPrint('Added created_at column to loans table (v6 migration).');
        }
      }

      // Ensure updated_at exists and is snake_case (if applicable, based on schema)
      // The _onCreate already includes updated_at, but if an older schema didn't, this would add it.
      // The initial error didn't mention updated_at, but it's good practice to ensure consistency.
      if (!loanColumnNames.contains('updated_at')) {
        if (loanColumnNames.contains('updatedAt')) {
          await db.execute('ALTER TABLE loans ADD COLUMN updated_at_temp TEXT');
          await db.execute('UPDATE loans SET updated_at_temp = updatedAt');
          await db.execute('ALTER TABLE loans DROP COLUMN updatedAt');
          await db.execute('ALTER TABLE loans RENAME COLUMN updated_at_temp TO updated_at');
          debugPrint('Renamed updatedAt to updated_at in loans table (v6 migration).');
        } else {
          await db.execute('ALTER TABLE loans ADD COLUMN updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP');
          debugPrint('Added updated_at column to loans table (v6 migration).');
        }
      }
    }
  }

  // Customer operations
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final maps = await db.query('customers', orderBy: 'created_at DESC');
    return maps.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // Loan operations
  Future<int> insertLoan(Loan loan) async {
    final db = await database;
    final loanMap = loan.toMap();
    debugPrint('Inserting loan: $loanMap'); // Added debug print
    return await db.insert('loans', loanMap);
  }

  Future<List<Loan>> getLoans() async {
    final db = await database;
    final maps = await db.query('loans', orderBy: 'created_at DESC');
    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  Future<List<Loan>> getLoansByCustomer(int customerId) async {
    final db = await database;
    final maps = await db.query(
      'loans',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Loan.fromMap(map)).toList();
  }

  Future<Loan?> getLoan(int id) async {
    final db = await database;
    final maps = await db.query('loans', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Loan.fromMap(maps.first);
  }

  Future<int> updateLoan(Loan loan) async {
    final db = await database;
    return await db.update(
      'loans',
      loan.toMap(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  Future<int> deleteLoan(int id) async {
    final db = await database;
    return await db.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  // Payment operations
  Future<int> insertPayment(Payment payment) async {
    final db = await database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getPayments() async {
    final db = await database;
    final maps = await db.query('payments', orderBy: 'payment_date DESC');
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<List<Payment>> getPaymentsByLoan(int loanId) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'loan_id = ?',
      whereArgs: [loanId],
      orderBy: 'payment_date DESC',
    );
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await database;
    final maps = await db.query('payments', orderBy: 'payment_date DESC');
    return maps.map((map) => Payment.fromMap(map)).toList();
  }

  // Utility methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('payments');
    await db.delete('loans');
    await db.delete('customers');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
