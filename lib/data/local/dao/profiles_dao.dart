import 'package:clashify/data/local/data_mappers.dart';
import 'package:clashify/data/local/database.dart';
import 'package:clashify/data/local/tables.dart';
import 'package:clashify/domain/profiles/profiles.dart';
import 'package:clashify/utils/utils.dart';
import 'package:drift/drift.dart';

part 'profiles_dao.g.dart';

@DriftAccessor(tables: [ProfileEntries])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin, InfraLogger {
  ProfilesDao(super.db);

  Future<Profile?> getById(String id) async {
    loggy.debug('getting profile, id: [$id]');
    return (profileEntries.select()..where((tbl) => tbl.id.equals(id)))
        .map(ProfileMapper.fromEntry)
        .getSingleOrNull();
  }

  Stream<Profile?> watchActiveProfile() {
    loggy.debug('watching active profile');
    return (profileEntries.select()..where((tbl) => tbl.active.equals(true)))
        .map(ProfileMapper.fromEntry)
        .watchSingleOrNull();
  }

  Stream<List<Profile>> watchAll() {
    loggy.debug('watching all profiles');
    return profileEntries.select().map(ProfileMapper.fromEntry).watch();
  }

  Future<void> create(Profile profile) async {
    await transaction(
      () async {
        if (profile.active) {
          await (update(profileEntries)
                ..where((tbl) => tbl.id.isNotValue(profile.id)))
              .write(const ProfileEntriesCompanion(active: Value(false)));
        }
        await into(profileEntries).insert(profile.toCompanion());
      },
    );
  }

  Future<void> edit(Profile patch) async {
    await transaction(
      () async {
        await (update(profileEntries)..where((tbl) => tbl.id.equals(patch.id)))
            .write(patch.toCompanion());
      },
    );
  }

  Future<void> setAsActive(String id) async {
    await transaction(
      () async {
        await (update(profileEntries)..where((tbl) => tbl.id.isNotValue(id)))
            .write(const ProfileEntriesCompanion(active: Value(false)));
        await (update(profileEntries)..where((tbl) => tbl.id.equals(id)))
            .write(const ProfileEntriesCompanion(active: Value(true)));
      },
    );
  }

  Future<void> removeById(String id) async {
    await transaction(
      () async {
        await (delete(profileEntries)..where((tbl) => tbl.id.equals(id))).go();
      },
    );
  }
}
