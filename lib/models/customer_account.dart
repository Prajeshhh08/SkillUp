class CustomerAccount {
  CustomerAccount._();

  static String fullName = 'SkillUp Customer';
  static String email = 'Add your email address';
  static String phone = 'Add your phone number';

  static void update({
    required String name,
    required String emailAddress,
    required String phoneNumber,
  }) {
    fullName = name.trim().isEmpty ? fullName : name.trim();
    email = emailAddress.trim().isEmpty ? email : emailAddress.trim();
    phone = phoneNumber.trim().isEmpty ? phone : phoneNumber.trim();
  }
}
