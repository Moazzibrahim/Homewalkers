class LeadCommentsModel {
  int? results;
  Pagination? pagination;
  List<DataItem>? data;

  LeadCommentsModel({this.results, this.pagination, this.data});

  factory LeadCommentsModel.fromJson(Map<String, dynamic> json) =>
      LeadCommentsModel(
        results: json["results"],
        pagination:
            json["pagination"] == null
                ? null
                : Pagination.fromJson(json["pagination"]),
        data:
            json["data"] == null
                ? null
                : List<DataItem>.from(
                  json["data"].map((x) => DataItem.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "results": results,
    "pagination": pagination?.toJson(),
    "data":
        data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Pagination {
  int? currentPage;
  int? limit;
  int? numberOfPages;

  Pagination({this.currentPage, this.limit, this.numberOfPages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    limit: json["limit"],
    numberOfPages: json["NumberOfPages"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "limit": limit,
    "NumberOfPages": numberOfPages,
  };
}

class DataItem {
  String? id;
  List<Comment>? comments;
  Leed? leed;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  DataItem({
    this.id,
    this.comments,
    this.leed,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory DataItem.fromJson(Map<String, dynamic> json) => DataItem(
    id: json["_id"],
    comments:
        json["Comments"] == null
            ? null
            : List<Comment>.from(
              json["Comments"].map((x) => Comment.fromJson(x)),
            ),
    leed: json["leed"] == null ? null : Leed.fromJson(json["leed"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "Comments":
        comments == null
            ? null
            : List<dynamic>.from(comments!.map((x) => x.toJson())),
    "leed": leed?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Comment {
  FirstComment? firstcomment;
  SecondComment? secondcomment;
  Sales? sales;
  Stage? stage;
  String? id;
  DateTime? stageDate;
  List<Reply>? replies;

  Comment({
    this.firstcomment,
    this.secondcomment,
    this.sales,
    this.stage,
    this.id,
    this.stageDate,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    firstcomment:
        json["firstcomment"] == null
            ? null
            : FirstComment.fromJson(json["firstcomment"]),
    secondcomment:
        json["secondcomment"] == null
            ? null
            : SecondComment.fromJson(json["secondcomment"]),
    sales: json["sales"] == null ? null : Sales.fromJson(json["sales"]),
    stage: json["stage"] == null ? null : Stage.fromJson(json["stage"]),
    id: json["_id"],
    stageDate:
        json["stageDate"] == null ? null : DateTime.parse(json["stageDate"]),
    replies:
        json["replies"] == null
            ? null
            : List<Reply>.from(json["replies"].map((x) => Reply.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "firstcomment": firstcomment?.toJson(),
    "secondcomment": secondcomment?.toJson(),
    "sales": sales?.toJson(),
    "stage": stage?.toJson(),
    "_id": id,
    "stageDate": stageDate?.toIso8601String(),
    "replies":
        replies == null
            ? null
            : List<dynamic>.from(replies!.map((x) => x.toJson())),
  };
}

class FirstComment {
  String? text;
  DateTime? date;

  FirstComment({this.text, this.date});

  factory FirstComment.fromJson(Map<String, dynamic> json) => FirstComment(
    text: json["text"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "date": date?.toIso8601String(),
  };
}

class SecondComment {
  String? text;
  DateTime? date;

  SecondComment({this.text, this.date});

  factory SecondComment.fromJson(Map<String, dynamic> json) => SecondComment(
    text: json["text"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "date": date?.toIso8601String(),
  };
}

class Reply {
  String? text;
  DateTime? date;
  String? id;

  Reply({this.text, this.date, this.id});

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
    text: json["text"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "date": date?.toIso8601String(),
    "_id": id,
  };
}

/// ====== LEED SECTION ======

class Leed {
  String? id;
  String? name;
  String? email;
  Project? project;
  Sales? sales;
  Stage? stage;
  Channel? chanel;
  CommunicationWay? communicationway;
  AddBy? addby;
  AddBy? updatedby;
  Campaign? campaign;

  Leed({
    this.id,
    this.name,
    this.email,
    this.project,
    this.sales,
    this.stage,
    this.chanel,
    this.communicationway,
    this.addby,
    this.updatedby,
    this.campaign,
  });

  factory Leed.fromJson(Map<String, dynamic> json) => Leed(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    project: json["project"] == null ? null : Project.fromJson(json["project"]),
    sales: json["sales"] == null ? null : Sales.fromJson(json["sales"]),
    stage: json["stage"] == null ? null : Stage.fromJson(json["stage"]),
    chanel: json["chanel"] == null ? null : Channel.fromJson(json["chanel"]),
    communicationway:
        json["communicationway"] == null
            ? null
            : CommunicationWay.fromJson(json["communicationway"]),
    addby: json["addby"] == null ? null : AddBy.fromJson(json["addby"]),
    updatedby:
        json["updatedby"] == null ? null : AddBy.fromJson(json["updatedby"]),
    campaign:
        json["campaign"] == null ? null : Campaign.fromJson(json["campaign"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "project": project?.toJson(),
    "sales": sales?.toJson(),
    "stage": stage?.toJson(),
    "chanel": chanel?.toJson(),
    "communicationway": communicationway?.toJson(),
    "addby": addby?.toJson(),
    "updatedby": updatedby?.toJson(),
    "campaign": campaign?.toJson(),
  };
}

class Project {
  String? id;
  String? name;
  Developer? developer;
  City? city;

  Project({this.id, this.name, this.developer, this.city});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json["_id"],
    name: json["name"],
    developer:
        json["developer"] == null
            ? null
            : Developer.fromJson(json["developer"]),
    city: json["city"] == null ? null : City.fromJson(json["city"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "developer": developer?.toJson(),
    "city": city?.toJson(),
  };
}

class Developer {
  String? id;
  String? name;

  Developer({this.id, this.name});

  factory Developer.fromJson(Map<String, dynamic> json) =>
      Developer(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class City {
  String? id;
  String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) =>
      City(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Sales {
  String? id;
  String? name;
  String? email;
  String? profileImg;
  String? role;
  bool? active;
  String? fcmToken;

  Sales({
    this.id,
    this.name,
    this.email,
    this.profileImg,
    this.role,
    this.active,
    this.fcmToken,
  });

  factory Sales.fromJson(Map<String, dynamic> json) => Sales(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    profileImg: json["profileImg"],
    role: json["role"],
    active: json["active"],
    fcmToken: json["fcmToken"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "profileImg": profileImg,
    "role": role,
    "active": active,
    "fcmToken": fcmToken,
  };
}

class Stage {
  String? id;
  String? name;
  StageType? stagetype;

  Stage({this.id, this.name, this.stagetype});

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    id: json["_id"],
    name: json["name"],
    stagetype:
        json["stagetype"] == null
            ? null
            : StageType.fromJson(json["stagetype"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "stagetype": stagetype?.toJson(),
  };
}

class StageType {
  String? id;
  String? name;

  StageType({this.id, this.name});

  factory StageType.fromJson(Map<String, dynamic> json) =>
      StageType(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class Channel {
  String? id;
  String? name;
  String? code;

  Channel({this.id, this.name, this.code});

  factory Channel.fromJson(Map<String, dynamic> json) =>
      Channel(id: json["_id"], name: json["name"], code: json["code"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "code": code};
}

class CommunicationWay {
  String? id;
  String? name;

  CommunicationWay({this.id, this.name});

  factory CommunicationWay.fromJson(Map<String, dynamic> json) =>
      CommunicationWay(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class AddBy {
  String? id;
  String? name;
  String? email;
  String? role;

  AddBy({this.id, this.name, this.email, this.role});

  factory AddBy.fromJson(Map<String, dynamic> json) => AddBy(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "role": role,
  };
}

class Campaign {
  String? id;
  String? campainName;
  String? date;
  int? cost;
  bool? isactivate;
  AddBy? addby;
  AddBy? updatedby;

  Campaign({
    this.id,
    this.campainName,
    this.date,
    this.cost,
    this.isactivate,
    this.addby,
    this.updatedby,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    id: json["_id"],
    campainName: json["CampainName"],
    date: json["Date"],
    cost: json["Cost"],
    isactivate: json["isactivate"],
    addby: json["addby"] == null ? null : AddBy.fromJson(json["addby"]),
    updatedby:
        json["updatedby"] == null ? null : AddBy.fromJson(json["updatedby"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "CampainName": campainName,
    "Date": date,
    "Cost": cost,
    "isactivate": isactivate,
    "addby": addby?.toJson(),
    "updatedby": updatedby?.toJson(),
  };
}
