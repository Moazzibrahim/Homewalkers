class LeadCommentsModel {
  int? results;
  Pagination? pagination;
  List<DataItem>? data;

  LeadCommentsModel({
    this.results,
    this.pagination,
    this.data,
  });

  factory LeadCommentsModel.fromJson(Map<String, dynamic> json) => LeadCommentsModel(
        results: json["results"],
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
        data: json["data"] == null ? null : List<DataItem>.from(json["data"].map((x) => DataItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "results": results,
        "pagination": pagination?.toJson(),
        "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Pagination {
  int? currentPage;
  int? limit;
  int? numberOfPages;

  Pagination({
    this.currentPage,
    this.limit,
    this.numberOfPages,
  });

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
  dynamic leed;
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
        comments: json["Comments"] == null ? null : List<Comment>.from(json["Comments"].map((x) => Comment.fromJson(x))),
        leed: json["leed"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "Comments": comments == null ? null : List<dynamic>.from(comments!.map((x) => x.toJson())),
        "leed": leed,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Comment {
  FirstComment? firstcomment;
  SecondComment? secondcomment;
  dynamic sales;
  String? id;
  DateTime? stageDate;
  List<Reply>? replies;

  Comment({
    this.firstcomment,
    this.secondcomment,
    this.sales,
    this.id,
    this.stageDate,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        firstcomment: json["firstcomment"] == null ? null : FirstComment.fromJson(json["firstcomment"]),
        secondcomment: json["secondcomment"] == null ? null : SecondComment.fromJson(json["secondcomment"]),
        sales: json["sales"],
        id: json["_id"],
        stageDate: json["stageDate"] == null ? null : DateTime.parse(json["stageDate"]),
                replies: json["replies"] == null ? null : List<Reply>.from(json["replies"].map((x) => Reply.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "firstcomment": firstcomment?.toJson(),
        "secondcomment": secondcomment?.toJson(),
        "sales": sales,
        "_id": id,
        "stageDate": stageDate?.toIso8601String(),
        "replies": replies == null ? null : List<dynamic>.from(replies!.map((x) => x)),
      };
}

class FirstComment {
  String? text;
  DateTime? date;

  FirstComment({
    this.text,
    this.date,
  });

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

  SecondComment({
    this.text,
    this.date,
  });

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

  Reply({ this.text, this.date, this.id});

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