class Validators {
  static bool isValidName(String name) {
    return name.isNotEmpty && name.length >= 2;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidRegistrationNumber(String registrationNumber) {
    return registrationNumber.isNotEmpty;
  }

  static bool isValidVehicleType(String type) {
    const validTypes = ['Car', 'Motorcycle', 'Truck'];
    return validTypes.contains(type);
  }
}
