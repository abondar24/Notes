extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get count => map((event) => event.length);
}
