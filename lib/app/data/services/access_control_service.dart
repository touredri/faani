import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faani/app/data/models/user_role.dart';
import 'package:faani/app/firebase/global_function.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessControlService {
  static const String _roleCachePrefix = 'role_';

  Future<AppUserRole> getCurrentUserRole({bool forceRefresh = false}) async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return AppUserRole.client;
    }

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_roleCachePrefix$uid';

    if (!forceRefresh) {
      final cachedRole = prefs.getString(cacheKey);
      if (cachedRole != null && cachedRole.trim().isNotEmpty) {
        return appUserRoleFromString(cachedRole);
      }
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();

    AppUserRole role = AppUserRole.client;
    final String? roleRaw = userData?['role']?.toString();
    if ((roleRaw ?? '').trim().isNotEmpty) {
      role = appUserRoleFromString(roleRaw);
    } else {
      final isTailleur = userData?['isTailleur'] == true;
      role = isTailleur ? AppUserRole.tailor : AppUserRole.client;
    }

    final adminDoc =
        await FirebaseFirestore.instance.collection('admin').doc(uid).get();
    if (adminDoc.exists) {
      role = AppUserRole.admin;
    }

    await prefs.setString(cacheKey, appUserRoleToString(role));

    if (userDoc.exists && roleRaw != appUserRoleToString(role)) {
      await userDoc.reference.update({
        'role': appUserRoleToString(role),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return role;
  }

  Future<bool> isCurrentUserAdmin({bool forceRefresh = false}) async {
    final role = await getCurrentUserRole(forceRefresh: forceRefresh);
    return role == AppUserRole.admin;
  }

  bool can(AppUserRole role, AppPermission permission) {
    switch (permission) {
      case AppPermission.viewAdminPanel:
      case AppPermission.manageUsers:
      case AppPermission.manageTailorRequests:
      case AppPermission.moderateModels:
        return role == AppUserRole.admin;
      case AppPermission.manageOwnClients:
        return role == AppUserRole.tailor || role == AppUserRole.admin;
    }
  }

  Future<void> clearCachedRoleForCurrentUser() async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_roleCachePrefix$uid');
  }
}
