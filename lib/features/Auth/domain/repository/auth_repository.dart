abstract class AuthRepository {
  Future<dynamic> getLoginToken(String email, String deviceId);
  Future<void> register(Map<String, dynamic> formData);
  Future<void> addCompanyInformation(Map<String, dynamic> data);
}
