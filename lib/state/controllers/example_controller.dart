import 'package:flutter/widgets.dart';
import '../providers/example_provider.dart';

class ExampleController {
  ExampleController(this._provider);

  final ExampleProvider _provider;

  Listenable get listenable => _provider;

  Future<void> initialize() => _provider.load();
}