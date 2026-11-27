import 'package:flutter/material.dart';
import '../models/agent_model.dart';
import '../services/valorant_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/error_state_widget.dart';

class AgentListScreen extends StatefulWidget {
  const AgentListScreen({Key? key}) : super(key: key);

  @override
  State<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends State<AgentListScreen> {
  final ValorantService _valorantService = ValorantService();
  
  List<AgentModel> _allAgents = [];
  List<AgentModel> _filteredAgents = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  String _searchQuery = '';
  String _selectedRole = 'All';

  final List<String> _roles = ['All', 'Duelist', 'Initiator', 'Controller', 'Sentinel'];

  @override
  void initState() {
    super.initState();
    _fetchAgentsData();
  }

  Future<void> _fetchAgentsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final agents = await _valorantService.fetchAgents();
      if (!mounted) return;
      setState(() {
        _allAgents = agents;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredAgents = _allAgents.where((agent) {
        final matchesSearch = agent.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesRole = _selectedRole == 'All' || 
            (agent.roleName?.toLowerCase() == _selectedRole.toLowerCase());
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'VALORANT AGENTS', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1E2E), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar & Filter Chips Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        // Search Field
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          onChanged: (value) {
                            _searchQuery = value;
                            _applyFilter();
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari Agent...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.6)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.06),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Horizontal Role Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _roles.map((role) {
                              final isSelected = _selectedRole == role;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(role),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFFFF4655),
                                  backgroundColor: Colors.white.withOpacity(0.08),
                                  side: BorderSide(
                                    color: isSelected 
                                        ? const Color(0xFFFF4655) 
                                        : Colors.white.withOpacity(0.1),
                                  ),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[300],
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedRole = role;
                                        _applyFilter();
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Grid Content Area
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF4655)),
                      )
                    : _errorMessage != null
                        ? ErrorStateWidget(
                            message: _errorMessage!,
                            onRetry: _fetchAgentsData,
                          )
                        : _filteredAgents.isEmpty
                            ? Center(
                                child: Text(
                                  'Agent tidak ditemukan',
                                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                                ),
                              )
                            : RefreshIndicator(
                                color: const Color(0xFFFF4655),
                                backgroundColor: const Color(0xFF1E1E2E),
                                onRefresh: _fetchAgentsData,
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.78,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: _filteredAgents.length,
                                  itemBuilder: (context, index) {
                                    final agent = _filteredAgents[index];
                                    return GlassCard(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () => _showAgentDetailBottomSheet(agent),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Agent Icon
                                              Expanded(
                                                child: agent.displayIcon != null && agent.displayIcon!.isNotEmpty
                                                    ? Image.network(
                                                        agent.displayIcon!,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (_, __, ___) => const Icon(
                                                          Icons.person_rounded,
                                                          size: 48,
                                                          color: Colors.white54,
                                                        ),
                                                      )
                                                    : const Icon(
                                                        Icons.person_rounded,
                                                        size: 48,
                                                        color: Colors.white54,
                                                      ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Name Agent
                                              Text(
                                                agent.displayName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              // Role Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF4655).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFFFF4655), width: 0.8),
                                                ),
                                                child: Text(
                                                  agent.roleName ?? 'AGENT',
                                                  style: const TextStyle(
                                                    color: Color(0xFFFF4655),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOTTOM SHEET DETAIL AGENT
  void _showAgentDetailBottomSheet(AgentModel agent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF4655),
                    blurRadius: 20,
                    spreadRadius: -8,
                  )
                ],
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Handle Bar Modal
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero Portrait Image
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: agent.fullPortrait != null && agent.fullPortrait!.isNotEmpty
                          ? Image.network(
                              agent.fullPortrait!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.network(agent.displayIcon ?? '', height: 120),
                            )
                          : (agent.displayIcon != null ? Image.network(agent.displayIcon!, height: 120) : const Icon(Icons.person, size: 80, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Agent Name & Role
                  Center(
                    child: Column(
                      children: [
                        Text(
                          agent.displayName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (agent.roleIcon != null && agent.roleIcon!.isNotEmpty)
                              Image.network(agent.roleIcon!, width: 16, height: 16, color: const Color(0xFFFF4655)),
                            const SizedBox(width: 6),
                            Text(
                              agent.roleName ?? 'AGENT',
                              style: const TextStyle(
                                color: Color(0xFFFF4655),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // BASE STATS SECTION
                  const Text(
                    'BASE STATS',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  _buildStatBar('Base Health', 100, 100, Colors.greenAccent),
                  _buildStatBar('Shield / Armor', 50, 50, Colors.lightBlueAccent),
                  _buildStatBar('Mobility / Stamina', 85, 100, const Color(0xFFFF4655)),

                  const SizedBox(height: 20),

                  // BIOGRAPHY SECTION
                  const Text(
                    'BIOGRAPHY',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    agent.description ?? 'Tidak ada deskripsi tersedia.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                  ),

                  const SizedBox(height: 24),

                  // SPECIAL ABILITIES SECTION
                  if (agent.abilities.isNotEmpty) ...[
                    const Text(
                      'SPECIAL ABILITIES',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: agent.abilities.map((ability) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4655).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ability.displayIcon != null && ability.displayIcon!.isNotEmpty
                                    ? Image.network(
                                        ability.displayIcon!,
                                        color: Colors.white,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                                      )
                                    : const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ability.displayName,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            ability.slot,
                                            style: const TextStyle(color: Color(0xFFFF4655), fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ability.description ?? '',
                                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper Widget Progress Bar
  Widget _buildStatBar(String label, double value, double max, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              Text(
                '${value.toInt()} / ${max.toInt()}', 
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / max,
            backgroundColor: Colors.white.withOpacity(0.08),
            color: color,
            minHeight: 5,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}