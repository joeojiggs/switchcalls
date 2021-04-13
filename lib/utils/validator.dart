mixin FormValidator {
  String validatePhone(String value) {
    if (value.length == 0) {
      return 'Please enter your phone number';
    }
    if (value.length < 5) {
      return "Please enter a valid phone number";
    }
    return null;
  }

  String validatePin(String value) {
    if (value.length == 0) {
      return 'Please enter pin';
    }
    if (value.length < 6) {
      return "Please enter complete OTP code";
    }
    return null;
  }
}
