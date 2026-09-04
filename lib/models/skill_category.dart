class SkillCategory {
  const SkillCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final bool isActive;

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    return SkillCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      iconUrl: json['icon_url']?.toString(),
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    if (description != null) 'description': description,
    if (iconUrl != null) 'icon_url': iconUrl,
    'is_active': isActive,
  };
}
