// To parse this JSON data, do
//
//     final misReportResponse = misReportResponseFromJson(jsonString);

import 'dart:convert';

MisReportResponse misReportResponseFromJson(String str) =>
    MisReportResponse.fromJson(json.decode(str));

String misReportResponseToJson(MisReportResponse data) =>
    json.encode(data.toJson());

class MisReportResponse {
  final int statusCode;
  final int status;
  final MisReportList misReportList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  MisReportResponse({
    required this.statusCode,
    required this.status,
    required this.misReportList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory MisReportResponse.fromJson(Map<String, dynamic> json) =>
      MisReportResponse(
        statusCode: json["statusCode"] ?? 0,
        status: json["status"] ?? 0,
        misReportList: json["data"] != null
            ? MisReportList.fromJson(json["data"])
            : MisReportList(docketLists: []),
        errors: json["errors"],
        metaData: json["metaData"],
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": misReportList.toJson(),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class MisReportList {
  final List<DocketList> docketLists;

  MisReportList({
    required this.docketLists,
  });

  factory MisReportList.fromJson(Map<String, dynamic> json) => MisReportList(
    docketLists: json["docketLists"] == null
        ? []
        : List<DocketList>.from(
        json["docketLists"].map((x) => DocketList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "docketLists": List<dynamic>.from(docketLists.map((x) => x.toJson())),
  };
}

class DocketList {
  final String dockno;
  final String docketDate;
  final String fromCity;
  final String toCity;
  final String consignorName;
  final String consigneeName;
  final num noOfBoxes;
  final num actuwt;
  final String edd;
  final String status;
  final String delivery;

  DocketList({
    required this.dockno,
    required this.docketDate,
    required this.fromCity,
    required this.toCity,
    required this.consignorName,
    required this.consigneeName,
    required this.noOfBoxes,
    required this.actuwt,
    required this.edd,
    required this.status,
    required this.delivery,
  });

  factory DocketList.fromJson(Map<String, dynamic> json) => DocketList(
    dockno: json["dockno"]?.toString() ?? "",
    docketDate: json["docket_Date"]?.toString() ?? "",
    fromCity: json["from_City"]?.toString() ?? "",
    toCity: json["to_City"]?.toString() ?? "",
    consignorName: json["consignor_Name"]?.toString() ?? "",
    consigneeName: json["consignee_Name"]?.toString() ?? "",
    noOfBoxes: json["no_Of_Boxes"] ?? 0,
    actuwt: json["actuwt"] ?? 0,
    edd: json["edd"]?.toString() ?? "",
    status: json["status"]?.toString() ?? "",
    delivery: json["delivery"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "dockno": dockno,
    "docket_Date": docketDate,
    "from_City": fromCity,
    "to_City": toCity,
    "consignor_Name": consignorName,
    "consignee_Name": consigneeName,
    "no_Of_Boxes": noOfBoxes,
    "actuwt": actuwt,
    "edd": edd,
    "status": status,
    "delivery": delivery,
  };
}
