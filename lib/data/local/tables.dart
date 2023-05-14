import 'package:clashify/data/local/type_converters.dart';
import 'package:drift/drift.dart';

@DataClassName('ProfileEntry')
class ProfileEntries extends Table {
  TextColumn get id => text()();
  BoolColumn get active => boolean()();
  TextColumn get name => text().withLength(min: 1)();
  TextColumn get url => text()();
  IntColumn get upload => integer().nullable()();
  IntColumn get download => integer().nullable()();
  IntColumn get total => integer().nullable()();
  DateTimeColumn get expire => dateTime().nullable()();
  IntColumn get updateInterval =>
      integer().nullable().map(DurationTypeConverter())();
  DateTimeColumn get lastUpdate => dateTime()();
}
