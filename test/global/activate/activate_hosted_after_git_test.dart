// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart';
import 'package:test/test.dart';

import '../../descriptor.dart' as d;
import '../../test_pub.dart';

void main() {
  test('activating a hosted package deactivates the Git one', () async {
    final server = await servePackages();
    server.serve('foo', '2.0.0', contents: [
      d.dir('bin', [d.file('foo.dart', "main(args) => print('hosted');")])
    ]);

    await d.git('foo.git', [
      d.libPubspec('foo', '1.0.0'),
      d.dir('bin', [d.file('foo.dart', "main() => print('git');")])
    ]).create();

    await runPub(args: ['global', 'activate', '-sgit', '../foo.git']);

    await runPub(
        args: ['global', 'activate', 'foo'],
        output: allOf([
          contains(
              'Package foo is currently active from Git repository "..${separator}foo.git".'),
          contains('* foo 2.0.0 (was 1.0.0 from git ..${separator}foo.git at'),
          contains('Activated foo 2.0.0.')
        ]));

    // Should now run the hosted one.
    var pub = await pubRun(global: true, args: ['foo']);
    expect(pub.stdout, emits('hosted'));
    await pub.shouldExit();
  });
}
