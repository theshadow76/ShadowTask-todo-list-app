String signupValidator(String email, String password, String confirmPassword) {
  if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    return "Error : Empty field!";
  } else {
    if (!email.contains("@")) {
      return "Error : Invalid email format";
    } else {
      if (password.length < 6) {
        return "Error : Password must contain 6 letters";
      } else {
        if (password != confirmPassword) {
          return "Error : Password miss match";
        } else {
          return "Success";
        }
      }
    }
  }
}

String loginValidator(String email, String password) {
  if (email.isEmpty || password.isEmpty) {
    return "Error : Empty field!";
  } else {
    if (!email.contains("@")) {
      return "Error : Invalid email format";
    } else {
      if (password.length < 6) {
        return "Error : Password must contain 6 letters";
      } else {
        return "Success";
      }
    }
  }
}
