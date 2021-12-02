class EmergencyDependee {
  String nickName;
  String email;
  String uid;

  EmergencyDependee(this.nickName, this.email, this.uid);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> retVal = {
      "email": email,
      "nickname": nickName,
      "uid": uid
    };

    return retVal;
  }

  String toString() => "Email: $email, Nickname: $nickName, UID: $uid";
}
