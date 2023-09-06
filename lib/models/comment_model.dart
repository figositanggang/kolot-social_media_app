class CommentModel {
  final String comment;
  final String userId;

  CommentModel({
    required this.comment,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        "comment": comment,
        "userId": userId,
      };

  static CommentModel fromSnap(Map<String, dynamic> snapshot) {
    final snap = snapshot;

    return CommentModel(
      comment: snap['comment'],
      userId: snap['userId'],
    );
  }
}
