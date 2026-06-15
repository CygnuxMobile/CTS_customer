import 'dart:convert';

DocketTrackingResponse docketTrackingResponseFromJson(String str) => DocketTrackingResponse.fromJson(json.decode(str));

String docketTrackingResponseToJson(DocketTrackingResponse data) => json.encode(data.toJson());

class DocketTrackingResponse {
  final int? statusCode;
  final int? status;
  final Data? data;
  final dynamic errors;
  final dynamic metaData;
  final String? message;

  DocketTrackingResponse({this.statusCode, this.status, this.data, this.errors, this.metaData, this.message});

  factory DocketTrackingResponse.fromJson(Map<String, dynamic> json) => DocketTrackingResponse(
    statusCode: json["statusCode"],
    status: json["status"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": data?.toJson(),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class Data {
  final List<DocketList> docketLists;

  Data({required this.docketLists});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(docketLists: json["docketLists"] == null ? [] : List<DocketList>.from(json["docketLists"].map((x) => DocketList.fromJson(x))));

  Map<String, dynamic> toJson() => {"docketLists": List<dynamic>.from(docketLists.map((x) => x.toJson()))};
}

class DocketList {
  final String dockno;
  final String orgncd;
  final String destcd;
  final String froMLoc;
  final String tOLoc;
  final String oPStatus;
  final String csgnnm;
  final num pkgsno;
  final num actuwt;
  final num dkttot;
  final String edd;
  final String add;
  final String dockdt;
  final String? podlink;
  final bool isView;

  DocketList({
    required this.dockno,
    required this.orgncd,
    required this.destcd,
    required this.froMLoc,
    required this.tOLoc,
    required this.oPStatus,
    required this.csgnnm,
    required this.pkgsno,
    required this.actuwt,
    required this.dkttot,
    required this.dockdt,
    required this.edd,
    required this.add,
    this.podlink,
    this.isView = false,
  });

  factory DocketList.fromJson(Map<String, dynamic> json) => DocketList(
    dockno: json["dockno"] ?? "",
    orgncd: json["orgncd"] ?? "",
    destcd: json["destcd"] ?? "",
    froMLoc: json["froM_LOC"] ?? "",
    tOLoc: json["tO_LOC"] ?? "",
    csgnnm: json["csgnnm"] ?? '',
    pkgsno: json["pkgsno"] ?? 0.0,
    actuwt: json["actuwt"] ?? 0.0,
    dkttot: json["dkttot"] ?? 0.0,
    oPStatus: json["oP_STATUS"] ?? "",
    dockdt: json["dockdt"] ?? '',
    edd: json["edd"] ?? "",
    add: json["add"] ?? "",
    podlink: json["podlink"],
    isView: false,
  );

  Map<String, dynamic> toJson() => {
    "dockno": dockno,
    "orgncd": orgncd,
    "destcd": destcd,
    "froM_LOC": froMLoc,
    "tO_LOC": tOLoc,
    "oP_STATUS": oPStatus,
    "edd": edd,
    "add": add,
    "podlink": podlink,
    "isView": isView,
  };
}
