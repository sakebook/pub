// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:pub/src/exit_codes.dart' as exit_codes;
import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';
import 'utils.dart';

void main() {
  test('--force publishes if there are no warnings or errors', () async {
    await servePackages();
    await d.validPackage.create();
    await d.credentialsFile(globalServer, 'access token').create();
    var pub = await startPublish(globalServer, args: ['--force']);

    handleUploadForm(globalServer);
    handleUpload(globalServer);

    globalServer.expect('GET', '/create', (request) {
      return shelf.Response.ok(jsonEncode({
        'success': {'message': 'Package test_pkg 1.0.0 uploaded!'}
      }));
    });

    await pub.shouldExit(exit_codes.SUCCESS);
    expect(pub.stdout, emitsThrough('Package test_pkg 1.0.0 uploaded!'));
  });
}
