import 'dart:math';

class TestShuffle {
  TestShuffle._();

  static List<T> deterministic<T>(List<T> items, String seed) {
    final List<T> shuffled = List<T>.of(items);
    shuffled.shuffle(Random(seed.hashCode));

    return List<T>.unmodifiable(shuffled);
  }
}
