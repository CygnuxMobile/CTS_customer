class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final String? readAt;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.readAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'time': time,
      'isRead': isRead ? 1 : 0,
      'readAt': readAt,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      time: map['time'],
      isRead: map['isRead'] == 1,
      readAt: map['readAt'],
    );
  }
}
