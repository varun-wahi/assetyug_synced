abstract class AuthRepository {
  Future<dynamic> login(String email, String deviceId);
  Future<void> register(Map<String, dynamic> formData);
  Future<void> addCompanyInformation(Map<String, dynamic> data);
}
