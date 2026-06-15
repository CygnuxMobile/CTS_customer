import 'dart:convert';

GetLocationMasterData getLocationMasterDataFromJson(String str) =>
    GetLocationMasterData.fromJson(json.decode(str));

String getLocationMasterDataToJson(GetLocationMasterData data) => json.encode(data.toJson());

class GetLocationMasterData {
  GetLocationMasterData({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  final int statusCode;
  final int status;
  List<LocationList> data;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  factory GetLocationMasterData.fromJson(Map<String, dynamic> json) => GetLocationMasterData(
    statusCode: json["statusCode"],
    status: json["status"],
    data: List<LocationList>.from(json["data"].map((x) => LocationList.fromJson(x))),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class LocationList {
  LocationList({this.locCode, this.locName});

  final String? locCode;
  final String? locName;

  factory LocationList.fromJson(Map<String, dynamic> json) =>
      LocationList(locCode: json["locCode"], locName: json["locName"]);

  Map<String, dynamic> toJson() => {"locCode": locCode, "locName": locName};
}
