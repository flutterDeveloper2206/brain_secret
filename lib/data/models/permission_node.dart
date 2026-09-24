class PermissionNode {
  const PermissionNode({
    required this.actionCode,
    required this.title,
    required this.route,
    required this.icon,
    this.children = const [],
  });

  final int actionCode;
  final String title;
  final String route;
  final String icon;
  final List<PermissionNode> children;

  factory PermissionNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return PermissionNode(
      actionCode: json['actionCode'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      route: json['route'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      children: rawChildren is List
          ? rawChildren
                .whereType<Map>()
                .map(
                  (e) => PermissionNode.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionCode': actionCode,
      'title': title,
      'route': route,
      'icon': icon,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
