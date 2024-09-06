abstract class AssetModuleRepository {
  Future<dynamic> addExtraFields(Map<String, dynamic> data);
  Future<dynamic> getExtraFields(String id);
  Future<void> removeExtraField(String id);
  Future<dynamic> mandatoryFields(Map<String, dynamic> data);
  Future<dynamic> showFields(Map<String, dynamic> data);
  Future<dynamic> getMandatoryFields(String name, String email);
  Future<dynamic> getShowFields(String name, String email);
  Future<dynamic> getAllMandatoryFields(String email);
  Future<dynamic> getAllShowFields(String email);
  Future<void> deleteShowAndMandatoryFields(String name, String email);
}
