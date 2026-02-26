enum AppUserRole {
  client,
  tailor,
  admin,
}

enum AppPermission {
  viewAdminPanel,
  manageUsers,
  manageTailorRequests,
  moderateModels,
  manageOwnClients,
}

AppUserRole appUserRoleFromString(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'admin':
      return AppUserRole.admin;
    case 'tailor':
    case 'tailleur':
      return AppUserRole.tailor;
    default:
      return AppUserRole.client;
  }
}

String appUserRoleToString(AppUserRole role) {
  switch (role) {
    case AppUserRole.admin:
      return 'admin';
    case AppUserRole.tailor:
      return 'tailor';
    case AppUserRole.client:
      return 'client';
  }
}
