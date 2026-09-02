class SidebarUserModel {
  const SidebarUserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  factory SidebarUserModel.fromJson(Map<String, dynamic> json) {
    final String avatarUrl = (json['avatar_url'] ?? json['avatar'] ?? '')
        .toString()
        .trim();

    return SidebarUserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'avatar_url': avatarUrl,
  };
}
