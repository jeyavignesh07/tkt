
class TktHdrFields{
  static const String tktNo='tktNo';
  static const String tktTitle='tktTitle';
  static const String tktDesc='tktDesc';
  static const String tktCreatedBy='tktCreatedBy';
  static const String tktCreatedOn='tktCreatedOn';
  static const String tktReplyOn='tktReplyOn';
  static const String tktStatus = 'tktStatus';
}

class TktHdr {
  final String tktNo;
  final String tktTitle;
  final String tktDesc;
  final String tktCreatedBy;
  final String tktCreatedOn;
  final String tktReplyOn;
  final String tktStatus;
  const TktHdr(
      {required this.tktNo,
      required this.tktTitle,
      required this.tktDesc,
      required this.tktCreatedBy,
      required this.tktCreatedOn, 
      required this.tktReplyOn,
      required this.tktStatus,
      }
    );

  Map<String, Object?> toJson() => {
    TktHdrFields.tktNo: tktNo,
    TktHdrFields.tktTitle: tktTitle,
    TktHdrFields.tktDesc: tktDesc,
    TktHdrFields.tktCreatedBy: tktCreatedBy,
    TktHdrFields.tktCreatedOn: tktCreatedOn,
    TktHdrFields.tktReplyOn: tktReplyOn,
    TktHdrFields.tktStatus: tktStatus,
  };
  static TktHdr fromJson(Map<String, Object?> json)=>TktHdr(
    tktNo:json['tktNo'] as String,
    tktTitle: json['tktTitle'] as String,
    tktDesc: json['tktDesc'] as String,
    tktCreatedBy: json['tktCreatedBy'] as String,
    tktCreatedOn: json['tktCreatedOn'] as String,
    tktReplyOn: json['tktReplyOn'] as String,
    tktStatus: json['tktStatus'] as String,
  ); 
}

class TktDtlAssignFields{
  static const String tktNo='tktNo';
  static const String tktAssignedTo='tktAssignedTo';
}

class TktDtlAssign {
  final String tktNo;
  final String tktAssignedTo;

  const TktDtlAssign(
      {required this.tktNo,
      required this.tktAssignedTo
      });

  Map<String, Object?> toJson() => {
    TktDtlAssignFields.tktNo: tktNo,
    TktDtlAssignFields.tktAssignedTo: tktAssignedTo
  };
  static TktDtlAssign fromJson(Map<String, Object?> json)=>TktDtlAssign(
    tktNo:json['tktNo'] as String,
    tktAssignedTo: json['tktAssignedTo'] as String
  ); 
}

class TktDtlCopyFields{
  static const String tktNo='tktNo';
  static const String tktCopiedTo='tktCopiedTo';
}

class TktDtlCopy {
  final String tktNo;
  final String tktCopiedTo;

  const TktDtlCopy(
      {required this.tktNo,
      required this.tktCopiedTo});

  Map<String, Object?> toJson() => {
    TktDtlCopyFields.tktNo: tktNo,
    TktDtlCopyFields.tktCopiedTo: tktCopiedTo,
  };
  static TktDtlCopy fromJson(Map<String, Object?> json)=>TktDtlCopy(
    tktNo:json['tktNo'] as String,
    tktCopiedTo: json['tktCopiedTo'] as String,
  ); 
}

class TktStsCount {
  final String black;
  final String yellow;
  final String blue;
  final String red;
  const TktStsCount(
      {required this.black,
      required this.yellow,
      required this.blue,
      required this.red,
      }
    );
}