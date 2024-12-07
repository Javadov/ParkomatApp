import 'package:objectbox/objectbox.dart';
import 'package:parking_shared/objectbox.g.dart';
import '../models/user.dart';

class UserRepository {
  final Box<User> _userBox;

  UserRepository(Store store) : _userBox = store.box<User>();

  List<User> getAll() => _userBox.getAll();

  User? getByEmail(String email) {
    return _userBox.query(User_.email.equals(email)).build().findFirst();
  }

  void add(User user) => _userBox.put(user);

  void update(User user) => _userBox.put(user);

  void delete(int id) => _userBox.remove(id);
}
