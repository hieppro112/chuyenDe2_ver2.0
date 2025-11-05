class ProfileModel {
  String name;
  String email;
  String address;
  String phone;
  String avatarUrl;

  ProfileModel({
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.avatarUrl,
  });

  // Có thể thêm phương thức copyWith để dễ dàng cập nhật
  ProfileModel copyWith({
    String? name,
    String? email,
    String? address,
    String? phone,
    String? avatarUrl,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
