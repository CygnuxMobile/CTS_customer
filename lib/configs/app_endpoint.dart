class ApiEndPoint {
  static String baseUrl = "http://43.248.56.60:44379/V1/";

  static String login = "${baseUrl}Authenticate/Login";
  static String location = "${baseUrl}Master/GetLocationMasterData";
  static String docketTracking = "${baseUrl}Operation/GetCustomerData";
  static String GetCustMISReport = "${baseUrl}Operation/GetCustMISReport";
}
