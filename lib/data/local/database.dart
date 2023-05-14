import 'package:clashify/data/local/connection.dart';
import 'package:clashify/data/local/dao/dao.dart';
import 'package:clashify/data/local/tables.dart';
import 'package:clashify/data/local/type_converters.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(tables: [ProfileEntries], daos: [ProfilesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase({required QueryExecutor connection}) : super(connection);

  AppDatabase.connect() : super(connect());

  @override
  int get schemaVersion => 1;
}
