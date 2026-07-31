class EditProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? gender;
  final int? age;
  final int? weight;
  final int? height;
  final String? goal;
  final String? activityLevel;

  const EditProfileRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.goal,
    this.activityLevel,
  });

  /// Only serializes non-null fields so the server treats this as a
  /// proper partial update (PATCH-style semantics on a PUT endpoint).
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (email != null) data['email'] = email;
    if (gender != null) data['gender'] = gender;
    if (age != null) data['age'] = age;
    if (weight != null) data['weight'] = weight;
    if (height != null) data['height'] = height;
    if (goal != null) data['goal'] = goal;
    if (activityLevel != null) data['activityLevel'] = activityLevel;

    return data;
  }
}
