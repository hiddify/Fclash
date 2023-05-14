// import 'package:dio/dio.dart';
// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:fclash/data/local/dao/dao.dart';
// import 'package:fclash/data/local/database.dart';
// import 'package:fclash/data/repository/repository.dart';
// import 'package:fclash/domain/profiles/profiles.dart';
// import "package:flutter_test/flutter_test.dart";
// import 'package:loggy/loggy.dart';

// void main() {
//   late Dio dio;
//   late ProfilesDao profilesDao;
//   late ProfilesRepository profilesRepository;

//   setUpAll(
//     () {
//       Loggy.initLoggy();
//     },
//   );

//   setUp(
//     () async {
//       final inMemoryConnection = DatabaseConnection(NativeDatabase.memory());
//       final db = AppDatabase(connection: inMemoryConnection);
//       dio = Dio();
//       profilesDao = ProfilesDao(db);
//       profilesRepository = ProfilesRepositoryImpl(profilesDao, dio);
//     },
//   );

//   group(
//     '',
//     () {
//       test(
//         'sss',
//         () async {
//           await profilesRepository.addByUrl(
//               'https://conf.khiarshor.sbs/Pfl2lc1N00f/09e6b353-62ac-4e2c-89c9-7987aa4804dd/clash/all.yml');
//         },
//       );
//     },
//   );
// }
