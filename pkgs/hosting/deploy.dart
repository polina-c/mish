// Deploys the website to Firebase Hosting. The "deploy" configuration in
// .vscode/launch.json runs this script.
//
// It runs `firebase deploy --only hosting` in this folder. The predeploy hook
// in firebase.json builds the site first, so a plain `firebase deploy` here
// does the same thing.
import 'dart:io';

Future<void> main() async {
  final process = await Process.start(
    'firebase',
    ['deploy', '--only', 'hosting'],
    workingDirectory: Platform.script.resolve('.').toFilePath(),
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
