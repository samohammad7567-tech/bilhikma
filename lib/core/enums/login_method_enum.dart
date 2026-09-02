enum LoginMethod {
  phone('phone'),
  email('email');

  const LoginMethod(this.fieldName);

  final String fieldName;

  bool get isEmail => this == LoginMethod.email;

  LoginMethod get toggled => isEmail ? LoginMethod.phone : LoginMethod.email;

  static LoginMethod fromStorage(Object? value) =>
      value == LoginMethod.email.name ? LoginMethod.email : LoginMethod.phone;
}
