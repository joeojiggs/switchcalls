mixin FormValidator {
  String validatePhone(String value) {
    if (value.length == 0) {
      return 'Please enter your phone number';
    }
    if (value.length < 6) {
      return "Please enter a valid phone number";
    }
    if (!value.startsWith("0")) {
      return "Phone number should start with a zero";
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
