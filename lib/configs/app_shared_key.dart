import '../main.dart';

class LocalStorageKey {
  static const String token = "token";
  static const String roleName = "roleName";
  static const String fullName = "fullName";
  static const String pincode = "pincode";
  static const String mobile = "mobile";
  static const String userType = "userType";
  static const String email = "email";
  static const String roleId = "roleId";
  static const String isLogin = "isLogin";
  static const String userId = "userId";
  static const String locationName = "locationName";
  static const String locationCode = "locationCode";
  static const String fcmToken = "fcmToken";
}

class Pref {
  /// Clear all data
  static void clearData() {
    pref!.clear();
    setData(LocalStorageKey.isLogin, false);
  }

  /// Generic Getter
  static dynamic getData(String key) {
    switch (key) {
      case LocalStorageKey.token:
      case LocalStorageKey.roleName:
      case LocalStorageKey.fullName:
      case LocalStorageKey.pincode:
      case LocalStorageKey.mobile:
      case LocalStorageKey.userType:
      case LocalStorageKey.email:
      case LocalStorageKey.locationName:
      case LocalStorageKey.locationCode:
      case LocalStorageKey.fcmToken:
        return pref!.getString(key);

      case LocalStorageKey.roleId:
      case LocalStorageKey.userId:
        return pref!.getString(key);

      case LocalStorageKey.isLogin:
        return pref!.getBool(key);

      default:
        return null;
    }
  }

  /// Generic Setter
  static void setData(String key, dynamic value) {
    switch (key) {
      case LocalStorageKey.token:
      case LocalStorageKey.roleName:
      case LocalStorageKey.fullName:
      case LocalStorageKey.pincode:
      case LocalStorageKey.mobile:
      case LocalStorageKey.userType:
      case LocalStorageKey.email:
      case LocalStorageKey.locationName:
      case LocalStorageKey.locationCode:
      case LocalStorageKey.fcmToken:
        pref!.setString(key, value);
        break;

      case LocalStorageKey.roleId:
      case LocalStorageKey.userId:
        pref!.setString(key, value);
        break;

      case LocalStorageKey.isLogin:
        pref!.setBool(key, value);
        break;
    }
  }
}