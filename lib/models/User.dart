class User {
  final String username;
  final String profilePhoto;
  final Map<String, String>? rooms; // Добавляем поле rooms с типом Map<String, String>?

  User({required this.username, required this.profilePhoto, this.rooms});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      profilePhoto: json['profilePhoto'],
      rooms: json['rooms'] != null ? Map<String, String>.from(json['rooms']) : null,
    );
  }
}
