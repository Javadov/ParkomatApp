import 'package:objectbox/objectbox.dart';
import '../util/validators.dart';
import '../util/serializer.dart';
import '../util/identifiable.dart';

@Entity()
class User extends Identifiable {
  @override
  @Id()
  int id;

  String name;

  @Unique()
  String email;

  String password;

  User(this.name, this.email, this.password, [this.id = -1]);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['name'] as String,
      json['email'] as String,
      json['password'] as String,
      json['id'] as int? ?? 0,
    );
  }

  @override
  bool isValid() {
    return Validators.isValidName(name) &&
        Validators.isValidEmail(email) &&
        password.isNotEmpty;
  }

  @override
  String toString() {
    return "Id: $id, Name: $name, Email: $email";
  }
}

class UserSerializer extends Serializer<User> {
  @override
  Map<String, dynamic> toJson(User item) {
    return {
      'id': item.id,
      'name': item.name,
      'email': item.email,
      'password': item.password,
    };
  }

  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      json['name'] as String,
      json['email'] as String,
      json['password'] as String,
      json['id'] as int,
    );
  }
}
