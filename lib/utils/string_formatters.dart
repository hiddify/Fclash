import 'package:duration/duration.dart';

String formatExpireDuration(Duration dur) {
  return prettyDuration(
    dur,
    tersity: DurationTersity.day,
  );
}
