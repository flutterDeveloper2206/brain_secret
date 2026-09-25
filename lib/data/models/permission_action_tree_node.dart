class PermissionActionTreeNode {
  const PermissionActionTreeNode({
    required this.actionCode,
    required this.title,
    this.isChecked = false,
    this.isLeaf = false,
    this.children = const [],
  });

  /// API tree `key` — this is what must be sent in `action_codes`.
  final int actionCode;
  final String title;
  final bool isChecked;
  final bool isLeaf;
  final List<PermissionActionTreeNode> children;

  bool get hasChildren => children.isNotEmpty;

  /// Selectable for save when it is a leaf with a real API key.
  bool get isSaveableLeaf =>
      (isLeaf || !hasChildren) && actionCode > 0;

  factory PermissionActionTreeNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'] ??
        json['Children'] ??
        json['child'] ??
        json['Child'] ??
        json['nodes'] ??
        json['Nodes'] ??
        json['items'] ??
        json['Items'] ??
        json['subActions'] ??
        json['SubActions'] ??
        json['actionList'] ??
        json['ActionList'] ??
        json['childList'] ??
        json['ChildList'];

    final isLeafFlag = _asBool(json['isLeaf'] ?? json['IsLeaf'], false);
    final children = <PermissionActionTreeNode>[];
    if (!isLeafFlag && rawChildren is List) {
      for (final item in rawChildren) {
        if (item is Map) {
          children.add(
            PermissionActionTreeNode.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return PermissionActionTreeNode(
      actionCode: _resolveActionCode(json),
      title: _resolveTitle(json),
      isChecked: _asBool(
        json['is_checked'] ??
            json['isChecked'] ??
            json['IsChecked'] ??
            json['checked'] ??
            json['Checked'] ??
            json['selected'] ??
            json['Selected'] ??
            json['is_select'] ??
            json['isSelect'],
        false,
      ),
      isLeaf: isLeafFlag,
      children: children,
    );
  }

  static int _resolveActionCode(Map<String, dynamic> json) {
    // Live API uses Ant Design-style `key` (string) as the action id.
    final candidates = [
      json['key'],
      json['Key'],
      json['actionCode'],
      json['ActionCode'],
      json['action_code'],
      json['ACTION_CODE'],
      json['action_id'],
      json['actionId'],
      json['ActionId'],
      json['ActionID'],
      json['code'],
      json['Code'],
      json['value'],
      json['Value'],
      json['id'],
      json['Id'],
      json['ID'],
    ];
    for (final candidate in candidates) {
      final parsed = _asInt(candidate);
      if (parsed > 0) return parsed;
    }
    return 0;
  }

  static String _resolveTitle(Map<String, dynamic> json) {
    return json['title']?.toString() ??
        json['Title']?.toString() ??
        json['action_name']?.toString() ??
        json['actionName']?.toString() ??
        json['ActionName']?.toString() ??
        json['menu_name']?.toString() ??
        json['menuName']?.toString() ??
        json['MenuName']?.toString() ??
        json['name']?.toString() ??
        json['Name']?.toString() ??
        json['label']?.toString() ??
        json['Label']?.toString() ??
        json['text']?.toString() ??
        json['Text']?.toString() ??
        '';
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString().trim();
    if (text.isEmpty) return 0;
    return int.tryParse(text) ?? 0;
  }

  static bool _asBool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase().trim();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    return fallback;
  }
}

class PermissionActionTreeResponse {
  const PermissionActionTreeResponse({
    required this.statusCode,
    required this.message,
    required this.nodes,
  });

  final int statusCode;
  final String message;
  final List<PermissionActionTreeNode> nodes;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory PermissionActionTreeResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['Data'];
    final list = <PermissionActionTreeNode>[];

    void addNode(Map map) {
      list.add(
        PermissionActionTreeNode.fromJson(Map<String, dynamic>.from(map)),
      );
    }

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) addNode(item);
      }
    } else if (rawData is Map) {
      final nested = rawData['actions'] ??
          rawData['Actions'] ??
          rawData['sideBar'] ??
          rawData['SideBar'] ??
          rawData['tree'] ??
          rawData['Tree'] ??
          rawData['nodes'] ??
          rawData['Nodes'] ??
          rawData['children'] ??
          rawData['Children'] ??
          rawData['list'] ??
          rawData['List'] ??
          rawData['permissionActions'] ??
          rawData['PermissionActions'];
      if (nested is List) {
        for (final item in nested) {
          if (item is Map) addNode(item);
        }
      } else {
        addNode(rawData);
      }
    }

    final statusRaw =
        json['statusCode'] ?? json['StatusCode'] ?? json['status_code'];
    int statusCode = 0;
    if (statusRaw is int) {
      statusCode = statusRaw;
    } else if (statusRaw is num) {
      statusCode = statusRaw.toInt();
    } else {
      statusCode = int.tryParse(statusRaw?.toString() ?? '') ?? 0;
    }

    return PermissionActionTreeResponse(
      statusCode: statusCode,
      message: json['message']?.toString() ??
          json['Message']?.toString() ??
          'Unknown response',
      nodes: list,
    );
  }
}
