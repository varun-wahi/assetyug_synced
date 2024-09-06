abstract class AuthRepository {
  Future<dynamic> login(String email);
  Future<void> register(Map<String, dynamic> formData);
  Future<void> addCompanyInformation(Map<String, dynamic> data);
}
