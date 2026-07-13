abstract interface class UserProfileRepository {
  Future<void> updateProfile(
    String userId, {
    required String? name,
    required String? address,
    required String sex,
  });

  Future<void> updateClientTarget(String userId, String clientTarget);
}
