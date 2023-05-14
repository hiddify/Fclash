import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:loggy/loggy.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// HACK: required more testing

final _loggy = Loggy('<native connection>');

const databaseFileName = 'clashify.db';
const databasePortName = 'database_isolate_port';

Future<DatabaseConnection> asyncConnect({
  bool logStatements = false,
}) async {
  final driftIsolate = await getOrCreateDriftIsolate();
  return driftIsolate.connect(isolateDebugLog: logStatements).timeout(
    const Duration(seconds: 1),
    onTimeout: () async {
      _loggy.debug(
        "couldn't connect to received drift isolate, resetting process",
      );
      IsolateNameServer.removePortNameMapping(databasePortName);
      return asyncConnect(logStatements: logStatements);
    },
  );
}

/// Obtains a database connection for running drift in a Dart VM.
///
/// The [NativeDatabase] from drift will synchronously use sqlite3's C APIs.
/// To move synchronous database work off the main thread, we use a
/// [DriftIsolate], which can run queries in a background isolate under the
/// hood.
DatabaseConnection connect({bool logStatements = false}) {
  return DatabaseConnection.delayed(
    Future.sync(
      () => asyncConnect(logStatements: logStatements),
    ),
  );
}

Future<DriftIsolate> getOrCreateDriftIsolate() async {
  final dbPortOrNull = IsolateNameServer.lookupPortByName(databasePortName);
  if (dbPortOrNull != null) {
    _loggy.debug('previously registered port detected');
    return DriftIsolate.fromConnectPort(dbPortOrNull);
  }
  _loggy.debug("couldn't find an existing port, creating new isolate");
  final generatedIsolate = await _createDriftIsolate();
  final registrationResult = IsolateNameServer.registerPortWithName(
    generatedIsolate.connectPort,
    databasePortName,
  );
  _loggy.debug('created new drift isolate, registration: $registrationResult');
  return generatedIsolate;
}

Future<DriftIsolate> _createDriftIsolate() async {
  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'app.db');

  final receiveDriftIsolate = ReceivePort();
  await Isolate.spawn(
    _entrypointForDriftIsolate,
    _IsolateStartRequest(receiveDriftIsolate.sendPort, dbPath),
  );

  return await receiveDriftIsolate.first as DriftIsolate;
}

/// The entrypoint of isolates can only take a single message, but we need two
/// (a send port to reach the originating isolate and the database's path that
/// should be opened on the background isolate). So, we bundle this information
/// in a single class.
class _IsolateStartRequest {
  final SendPort talkToMain;
  final String databasePath;

  _IsolateStartRequest(this.talkToMain, this.databasePath);
}

/// The entrypoint for a background isolate launching a drift server.
///
/// The main isolate can then connect to that isolate server to transparently
/// run queries in the background.
void _entrypointForDriftIsolate(_IsolateStartRequest request) {
  // The native database synchronously uses sqlite3's C API with `dart:ffi` for
  // a fast database implementation that doesn't require platform channels.
  final databaseImpl = NativeDatabase(File(request.databasePath));

  // We can use DriftIsolate.inCurrent because this function is the entrypoint
  // of a background isolate itself.
  final driftServer =
      DriftIsolate.inCurrent(() => DatabaseConnection(databaseImpl));

  // Inform the main isolate about the server we just created.
  request.talkToMain.send(driftServer);
}
