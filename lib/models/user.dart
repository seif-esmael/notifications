class UserData {
  final String id;
  final String userName;
  final String email;
  final String phoneNumber;

  UserData(
    {
      required this.id, 
      required this.userName, 
      required this.email, 
      required this.phoneNumber
    }
  );

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      userName: json['userName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  
}
