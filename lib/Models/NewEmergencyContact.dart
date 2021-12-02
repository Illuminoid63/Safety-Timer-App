class NewEmergencyContact {
  String currentUserDisplayName;
  String email;

  NewEmergencyContact(this.currentUserDisplayName, this.email);

  String toString() =>
      "Email: $email, current user's display name: $currentUserDisplayName";
}
