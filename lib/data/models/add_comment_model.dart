class CommentResponse {
  final String status;
  final String message;
  final CommentData data;

  CommentResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      status: json['status'],
      message: json['message'],
      data: CommentData.fromJson(json['data']),
    );
  }
}

class CommentData {
  final List<Comment> comments;
  final String leed;
  final String id;
  final String createdAt;
  final String updatedAt;
  final int v;

  CommentData({
    required this.comments,
    required this.leed,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      comments: List<Comment>.from(
        json['Comments'].map((x) => Comment.fromJson(x)),
      ),
      leed: json['leed'],
      id: json['_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class Comment {
  final String sales;
  final CommentDetail firstComment;
  final CommentDetail secondComment;
  final String id;
  final String stageDate;
  final List<dynamic> replies;

  Comment({
    required this.sales,
    required this.firstComment,
    required this.secondComment,
    required this.id,
    required this.stageDate,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      sales: json['sales'],
      firstComment: CommentDetail.fromJson(json['firstcomment']),
      secondComment: CommentDetail.fromJson(json['secondcomment']),
      id: json['_id'],
      stageDate: json['stageDate'],
      replies: List<dynamic>.from(json['replies']),
    );
  }
}

class CommentDetail {
  final String text;
  final String date;

  CommentDetail({
    required this.text,
    required this.date,
  });

  factory CommentDetail.fromJson(Map<String, dynamic> json) {
    return CommentDetail(
      text: json['text'],
      date: json['date'],
    );
  }
}
