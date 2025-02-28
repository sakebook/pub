// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shelf/shelf.dart' as shelf;
import 'package:test/test.dart';

import '../descriptor.dart' as d;
import '../test_pub.dart';
import 'utils.dart';

void main() {
  test('cloud storage upload provides an error', () async {
    await servePackages();
    await d.validPackage.create();
    await d.credentialsFile(globalServer, 'access token').create();
    var pub = await startPublish(globalServer);

    await confirmPublish(pub);
    handleUploadForm(globalServer);

    globalServer.expect('POST', '/upload', (request) {
      return request.read().drain().then((_) {
        return shelf.Response.notFound(
            '<Error><Message>Your request sucked.</Message></Error>',
            headers: {'content-type': 'application/xml'});
      });
    });

    // TODO(nweiz): This should use the server's error message once the client
    // can parse the XML.
    expect(pub.stderr, emits('Failed to upload the package.'));
    await pub.shouldExit(1);
  });
}
