import 'package:objectbox/objectbox.dart';

abstract class Identifiable {
  @Id()
  int id = -1;

  bool isValid();
}
