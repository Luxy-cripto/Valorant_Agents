import 'package:flutter/material.dart';
import '../models/role_model.dart';
import '../models/agent_pool_model.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class AgentPoolFormScreen extends StatefulWidget {
  const AgentPoolFormScreen({Key? key}) : super(key: key);

  @override
  State<AgentPoolFormScreen> createState() => _AgentPoolFormScreenState();
}

class _AgentPoolFormScreenState extends State<AgentPoolFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _poolNameController = TextEditingController();
  final TextEditingController _signatureMapController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<RoleModel> _roles = [];
  List<AgentPoolModel> _myPools = [];
  int? _selectedRoleId;
  String? _selectedAgentName;
  bool _isLoadingRoles = true;
  bool _isLoadingPools = true;
  bool _isSubmitting = false;

  final List<String> _valorantAgents = [
    'Jett', 'Reyna', 'Raze', 'Phoenix', 'Yoru', 'Neon', 'Iso',
    'Sova', 'Fade', 'Breach', 'Skye', 'KAY/O', 'Gekko',
    'Brimstone', 'Omen', 'Viper', 'Astra', 'Harbor', 'Clove',
    'Sage', 'Cypher', 'Killjoy', 'Chamber', 'Deadlock'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchRoles();
    await _fetchMyPools();
  }

  Future<void> _fetchRoles() async {
    try {
      final roleList = await ApiService.getRoles();
      if (!mounted) return;
      setState(() {
        _roles = roleList
            .map((json) => RoleModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _isLoadingRoles = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRoles = false;
      });
    }
  }

  Future<void> _fetchMyPools() async {
    try {
      final poolList = await ApiService.getAgentPools();
      if (!mounted) return;
      setState(() {
        _myPools = poolList
            .map((json) => AgentPoolModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _isLoadingPools = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingPools = false;
      });
    }
  }

  Future<void> _submitAgentPool() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoleId == null) {
      _showSnackBar('Pilih Role (Parent) terlebih dahulu', Colors.orangeAccent);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await ApiService.createAgentPool({
        'role_id': _selectedRoleId,
        'title': _poolNameController.text.trim(),
        'pool_name': _poolNameController.text.trim(),
        'agent_name': _selectedAgentName ?? _poolNameController.text.trim(),
        'signature_map': _signatureMapController.text.trim(),
        'notes': _notesController.text.trim(),
      });

      final statusCode = response['statusCode'] ?? 200;

      if (statusCode == 200 || statusCode == 201) {
        _showSnackBar('Agent Pool berhasil disimpan!', Colors.greenAccent);
        _resetForm();
        _fetchMyPools();
      } else {
        String errorMsg = response['message'] ?? 'Gagal menyimpan ke server';
        if (response['errors'] != null) {
          final errors = response['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0].toString();
        }
        _showSnackBar(errorMsg, Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan jaringan', Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    _poolNameController.clear();
    _signatureMapController.clear();
    _notesController.clear();
    setState(() {
      _selectedRoleId = null;
      _selectedAgentName = null;
    });
  }

  void _showSnackBar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _poolNameController.dispose();
    _signatureMapController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Manage Agent Pool', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tambah Pool Baru',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          _isLoadingRoles
                              ? const LinearProgressIndicator(color: Color(0xFFFF4655))
                              : DropdownButtonFormField<int>(
                                  value: _selectedRoleId,
                                  dropdownColor: const Color(0xFF1E1E2E),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration('Pilih Role (Parent)', Icons.category),
                                  items: _roles.map((role) {
                                    return DropdownMenuItem<int>(
                                      value: role.id,
                                      child: Text(role.name),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => _selectedRoleId = val),
                                  validator: (val) => val == null ? 'Role wajib dipilih' : null,
                                ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _poolNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Nama Pool / Strategi', Icons.label_outline),
                            validator: (v) => v == null || v.isEmpty ? 'Nama pool harus diisi' : null,
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            value: _selectedAgentName,
                            dropdownColor: const Color(0xFF1E1E2E),
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Pilih Agent Valorant', Icons.person_search),
                            items: _valorantAgents.map((agent) {
                              return DropdownMenuItem<String>(
                                value: agent,
                                child: Text(agent),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedAgentName = val),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _signatureMapController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Signature Map (e.g., Ascent, Bind)', Icons.map_outlined),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration('Catatan Strategi', Icons.notes),
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4655),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _isSubmitting ? null : _submitAgentPool,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Simpan Pool', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Daftar Pool Saya',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _isLoadingPools
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4655)))
                    : _myPools.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text('Belum ada Agent Pool yang tersimpan.', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _myPools.length,
                            itemBuilder: (context, index) {
                              final pool = _myPools[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: GlassCard(
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFFFF4655),
                                      child: Icon(Icons.shield, color: Colors.white),
                                    ),
                                    title: Text(
                                      pool.poolName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Agent: ${pool.agentName} | Map: ${pool.signatureMap ?? "-"}',
                                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                    ),
                                    trailing: Text(
                                      pool.roleName ?? '',
                                      style: const TextStyle(color: Color(0xFFFF4655), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF4655)),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}