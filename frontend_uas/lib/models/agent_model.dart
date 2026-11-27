class AgentModel {
  final String uuid;
  final String displayName;
  final String? description;
  final String? displayIcon;
  final String? fullPortrait;
  final String? roleName;
  final String? roleIcon;
  final List<Ability> abilities;

  AgentModel({
    required this.uuid,
    required this.displayName,
    this.description,
    this.displayIcon,
    this.fullPortrait,
    this.roleName,
    this.roleIcon,
    required this.abilities,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    var rawAbilities = json['abilities'] as List? ?? [];
    List<Ability> abilityList = rawAbilities
        .where((a) => a['displayIcon'] != null) // Filter ability yang punya icon saja
        .map((a) => Ability.fromJson(a))
        .toList();

    return AgentModel(
      uuid: json['uuid'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'],
      displayIcon: json['displayIcon'],
      fullPortrait: json['fullPortrait'],
      roleName: json['role'] != null ? json['role']['displayName'] : null,
      roleIcon: json['role'] != null ? json['role']['displayIcon'] : null,
      abilities: abilityList,
    );
  }
}

class Ability {
  final String slot;
  final String displayName;
  final String? description;
  final String? displayIcon;

  Ability({
    required this.slot,
    required this.displayName,
    this.description,
    this.displayIcon,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      slot: json['slot'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'],
      displayIcon: json['displayIcon'],
    );
  }
}