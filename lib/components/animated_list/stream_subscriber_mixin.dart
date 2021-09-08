// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

/// Mixin for classes that own `StreamSubscription`s and expose an API for
/// disposing of themselves by cancelling the subscriptions
abstract class StreamSubscriberMixin<T> {
  final List<StreamSubscription<T>> _subscriptions = <StreamSubscription<T>>[];

  /// Listens to a stream and saves it to the list of subscriptions.
  void listen(Stream<T> stream, void Function(T data) onData,
      {Function? onError}) {
    _subscriptions.add(stream.listen(onData, onError: onError));
  }

  /// Cancels all streams that were previously added with listen().
  void cancelSubscriptions() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
  }
}
