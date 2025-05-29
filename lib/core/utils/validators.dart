class Validators {
  static bool isEmail(String input) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return emailRegex.hasMatch(input);
  }

  static bool isPhone(String input) {
    final phoneRegex = RegExp(r'^\d{11}$');
    return phoneRegex.hasMatch(input);
  }

  static bool isPasswordValid(String input) {
    return input.length >= 6;
  }
}
