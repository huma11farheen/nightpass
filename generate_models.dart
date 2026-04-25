import 'dart:io';
import 'dart:async';


Future<void> main() async {
  const  supabaseAnonKey =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmeGx2d3hqcG9xamVsbG10amlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ2OTUzNjYsImV4cCI6MjA1MDI3MTM2Nn0.A2qMjPHCCYQ7yWziKSwOMXsQLWNxCU73LSE-8FxvE3c';
  const  supabaseProjectId = 'wfxlvwxjpoqjellmtjij';
  const outputDir = 'lib/data/supabase_models';

  try {
    await deleteFolder(outputDir);

    runCommand('dart', [
      'run',
      'dart_openapi_model_gen',
      '-o',
      outputDir,
      '-i',
      'https://$supabaseProjectId.supabase.co/rest/v1/?apikey=$supabaseAnonKey'
    ]);
  } catch (e, st) {
    stderr.writeln('Error: $e\n\n$st');
    exit(1);
  }
}

Future<void> deleteFolder(String folder) async {
  final directory = Directory(folder);
  if (await directory.exists()) {
    await directory.delete(recursive: true);
    stdout.writeln('Deleted directory: $folder');
  }
}

Future<void> runCommand(String command, List<String> args) async {
  stdout.writeln('Running command: \n$command ${args.join(' ')}');
  final process = await Process.start(command, args,
      runInShell: true, mode: ProcessStartMode.inheritStdio);
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    stdout.writeln('Process exited with code $exitCode');
  }
}
