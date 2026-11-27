<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AgentPool;
use App\Models\Role;
use Illuminate\Http\Request;

class AgentPoolController extends Controller
{
    // GET /api/agent-pools
    public function index(Request $request)
    {
        $pools = AgentPool::with('role')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar Agent Pool milik user',
            'data' => $pools
        ]);
    }

    // POST /api/agent-pools
    public function store(Request $request)
    {
        $validated = $request->validate([
            'role_id' => 'required|exists:roles,id',
            'pool_name' => 'required|string|max:255',
            'agent_name' => 'nullable|string|max:255',
            'signature_map' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ]);

        // Cek apakah role ID valid di tabel roles
        $roleExists = Role::where('id', $validated['role_id'])->exists();
        if (!$roleExists) {
            return response()->json([
                'success' => false,
                'message' => 'Role ID tidak valid'
            ], 422);
        }

        // Jika tabel DB kamu memakai kolom 'title', isi title otomatis dari pool_name
        if (!isset($validated['title'])) {
            $validated['title'] = $validated['pool_name'];
        }

        $agentPool = $request->user()->agentPools()->create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Agent pool berhasil ditambahkan',
            'data' => $agentPool->load('role')
        ], 201);
    }

    // GET /api/agent-pools/{agent_pool}
    public function show(Request $request, $id)
    {
        $agentPool = AgentPool::with('role')
            ->where('user_id', $request->user()->id)
            ->find($id);

        if (!$agentPool) {
            return response()->json([
                'success' => false,
                'message' => 'Data agent pool tidak ditemukan atau bukan milik Anda'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail Agent Pool',
            'data' => $agentPool
        ]);
    }

    // PUT/PATCH /api/agent-pools/{agent_pool}
    public function update(Request $request, $id)
    {
        $agentPool = AgentPool::where('user_id', $request->user()->id)->find($id);

        if (!$agentPool) {
            return response()->json([
                'success' => false,
                'message' => 'Data agent pool tidak ditemukan atau bukan milik Anda'
            ], 404);
        }

        $validated = $request->validate([
            'role_id' => 'sometimes|required|exists:roles,id',
            'pool_name' => 'sometimes|required|string|max:255',
            'agent_name' => 'nullable|string|max:255',
            'signature_map' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ]);

        if (isset($validated['pool_name']) && !isset($validated['title'])) {
            $validated['title'] = $validated['pool_name'];
        }

        $agentPool->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Agent Pool berhasil diperbarui',
            'data' => $agentPool->load('role')
        ]);
    }

    // DELETE /api/agent-pools/{agent_pool}
    public function destroy(Request $request, $id)
    {
        $agentPool = AgentPool::where('user_id', $request->user()->id)->find($id);

        if (!$agentPool) {
            return response()->json([
                'success' => false,
                'message' => 'Data agent pool tidak ditemukan atau bukan milik Anda'
            ], 404);
        }

        $agentPool->delete();

        return response()->json([
            'success' => true,
            'message' => 'Agent Pool berhasil dihapus'
        ]);
    }
}