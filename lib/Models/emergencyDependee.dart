class EmergencyDependee {
  String nickName;
  String email;

  EmergencyDependee(this.nickName, this.email);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> retVal = {"email": email, "nickname": nickName};

    return retVal;
  }

  String toString() => "Email: $email, Nickname: $nickName";
}
