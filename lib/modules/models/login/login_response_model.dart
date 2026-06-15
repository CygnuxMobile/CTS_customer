class LoginResponseModel {
  LoginResponseModel({
      this.statusCode, 
      this.status, 
      this.data, 
      this.errors, 
      this.metaData, 
      this.message,});

  LoginResponseModel.fromJson(dynamic json) {
    statusCode = json['statusCode'];
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    errors = json['errors'] != null ? Errors.fromJson(json['errors']) : null;
    metaData = json['metaData'];
    message = json['message'];
  }
  int? statusCode;
  int? status;
  Data? data;
  Errors? errors;
  String? metaData;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['statusCode'] = statusCode;
    map['status'] = status;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    if (errors != null) {
      map['errors'] = errors?.toJson();
    }
    map['metaData'] = metaData;
    map['message'] = message;
    return map;
  }

}

class Errors {
  Errors({
      this.status, 
      this.message, 
      this.errors, 
      this.timeStamp,});

  Errors.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    errors = json['errors'];
    timeStamp = json['timeStamp'];
  }
  int? status;
  String? message;
  String? errors;
  String? timeStamp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    map['errors'] = errors;
    map['timeStamp'] = timeStamp;
    return map;
  }

}

class Data {
  Data({
      this.token, 
      this.tokenExpireTime, 
      this.userId, 
      this.name, 
      this.emailId, 
      this.userImage, 
      this.baseCompanyCode, 
      this.branchCode, 
      this.finYear, 
      this.multiLocation,});

  Data.fromJson(dynamic json) {
    token = json['token'];
    tokenExpireTime = json['tokenExpireTime'];
    userId = json['userId'];
    name = json['name'];
    emailId = json['emailId'];
    userImage = json['userImage'];
    baseCompanyCode = json['baseCompanyCode'];
    branchCode = json['branchCode'];
    finYear = json['finYear'];
    if (json['multiLocation'] != null) {
      multiLocation = [];
      json['multiLocation'].forEach((v) {
        multiLocation?.add(MultiLocation.fromJson(v));
      });
    }
  }
  String? token;
  String? tokenExpireTime;
  String? userId;
  String? name;
  String? emailId;
  dynamic userImage;
  String? baseCompanyCode;
  String? branchCode;
  String? finYear;
  List<MultiLocation>? multiLocation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    map['tokenExpireTime'] = tokenExpireTime;
    map['userId'] = userId;
    map['name'] = name;
    map['emailId'] = emailId;
    map['userImage'] = userImage;
    map['baseCompanyCode'] = baseCompanyCode;
    map['branchCode'] = branchCode;
    map['finYear'] = finYear;
    if (multiLocation != null) {
      map['multiLocation'] = multiLocation?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class MultiLocation {
  MultiLocation({
      this.locCode, 
      this.locName,});

  MultiLocation.fromJson(dynamic json) {
    locCode = json['locCode'];
    locName = json['locName'];
  }
  String? locCode;
  String? locName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['locCode'] = locCode;
    map['locName'] = locName;
    return map;
  }

}