// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'descriptor.dart' as d;
import 'test_pub.dart';

void main() {
  test('The bound of ">=2.11.0 <3.0.0" is not modified', () async {
    await d.dir(appPath, [
      d.pubspec({
        'name': 'myapp',
        'environment': {'sdk': '>=2.11.0 <3.0.0'}
      }),
    ]).create();

    await pubGet(
      error: contains(
          'Because myapp requires SDK version >=2.11.0 <3.0.0, version solving failed'),
      environment: {'_PUB_TEST_SDK_VERSION': '3.5.0'},
    );
  });
  test('The bound of ">=2.12.0 <3.1.0" is not modified', () async {
    await d.dir(appPath, [
      d.pubspec({
        'name': 'myapp',
        'environment': {'sdk': '>=2.12.0 <3.1.0'}
      }),
    ]).create();

    await pubGet(
      error: contains(
          'Because myapp requires SDK version >=2.12.0 <3.1.0, version solving failed'),
      environment: {'_PUB_TEST_SDK_VERSION': '3.5.0'},
    );
  });

  test('The bound of ">=2.11.0 <2.999.0" is not modified', () async {
    await d.dir(appPath, [
      d.pubspec({
        'name': 'myapp',
        'environment': {'sdk': '>=2.11.0 <2.999.0'}
      }),
    ]).create();

    await pubGet(
      error: contains(
          'Because myapp requires SDK version >=2.11.0 <2.999.0, version solving failed'),
      environment: {'_PUB_TEST_SDK_VERSION': '3.5.0'},
    );
  });

  test('The bound of ">=2.11.0 <3.0.0-0.0" is not modified', () async {
    await d.dir(appPath, [
      d.pubspec({
        'name': 'myapp',
        'environment': {'sdk': '>=2.11.0 <3.0.0-0.0'}
      }),
    ]).create();

    await pubGet(
      error: contains(
          'Because myapp requires SDK version >=2.11.0 <3.0.0-0.0, version solving failed'),
      environment: {'_PUB_TEST_SDK_VERSION': '3.5.0'},
    );
  });

  test('The bound of ">=2.12.0 <3.0.0" is modified', () async {
    await d.dir(appPath, [
      d.pubspec({
        'name': 'myapp',
        'environment': {'sdk': '>=2.12.0 <3.0.0'}
      }),
    ]).create();

    await pubGet(environment: {'_PUB_TEST_SDK_VERSION': '3.5.0'});
  });

  test('The bound of ">=2.12.0 <3.0.0-0" is modified', () async {
    // For the upper bound <3.0.0 is treated as <3.0.0-0, so they both have
    // the rewrite applied.
    await d.dir(appPath, [
      d.pubspec({
        'name': 'myapp',
        'environment': {'sdk': '>=2.12.0 <3.0.0-0'}
      }),
    ]).create();

    await pubGet(environment: {'_PUB_TEST_SDK_VERSION': '3.5.0'});
  });

  test(
      'The bound of ">=2.12.0 <3.0.0" is not compatible with prereleases of dart 4',
      () async {
    await d.dir(appPath, [
      d.pubspec({
        'name': 'myapp',
        'environment': {'sdk': '>=2.12.0 <3.0.0'}
      }),
    ]).create();

    await pubGet(
      environment: {'_PUB_TEST_SDK_VERSION': '4.0.0-alpha'},
      error: contains(
        'Because myapp requires SDK version >=2.12.0 <4.0.0, version solving failed.',
      ),
    );
  });
}
