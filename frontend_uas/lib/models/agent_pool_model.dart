class AgentPoolModel {
  final int? id;
  final int roleId;
  final String poolName;
  final String agentName;
  final String? signatureMap;
  final String? notes;
  final String? roleName; // dari join relation role di backend

  AgentPoolModel({
    this.id,
    required this.roleId,
    required this.poolName,
    required this.agentName,
    this.signatureMap,
    this.notes,
    this.roleName,
  });

  factory AgentPoolModel.fromJson(Map<String, dynamic> json) {
    return AgentPoolModel(
      id: json['id'],
      roleId: json['role_id'],
      poolName: json['pool_name'] ?? json['name'] ?? '',
      agentName: json['agent_name'] ?? '',
      signatureMap: json['signature_map'],
      notes: json['notes'],
      roleName: json['role'] != null ? json['role']['name'] : json['role_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'pool_name': poolName,
      'agent_name': agentName,
      'signature_map': signatureMap,
      'notes': notes,
    };
  }
}