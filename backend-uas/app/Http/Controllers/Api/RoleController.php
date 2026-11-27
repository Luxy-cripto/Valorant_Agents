<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Role;
use Illuminate\Http\Request;

class RoleController extends Controller
{
    // GET /api/roles
    public function index(Request $request)
    {
        // Ambil semua data master role agar bisa diakses oleh seluruh user
        $roles = Role::latest()->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar Role',
            'data' => $roles
        ]);
    }

    // POST /api/roles
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $role = Role::create([
            'user_id' => $request->user()->id,
            'name' => $validated['name'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Role berhasil ditambahkan',
            'data' => $role
        ], 201);
    }

    // GET /api/roles/{role}
    public function show(Request $request, $id)
    {
        $role = Role::find($id);

        if (!$role) {
            return response()->json([
                'success' => false,
                'message' => 'Data role tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Detail Role',
            'data' => $role
        ]);
    }

    // PUT/PATCH /api/roles/{role}
    public function update(Request $request, $id)
    {
        $role = Role::find($id);

        if (!$role) {
            return response()->json([
                'success' => false,
                'message' => 'Data role tidak ditemukan'
            ], 404);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $role->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Role berhasil diperbarui',
            'data' => $role
        ]);
    }

    // DELETE /api/roles/{role}
    public function destroy(Request $request, $id)
    {
        $role = Role::find($id);

        if (!$role) {
            return response()->json([
                'success' => false,
                'message' => 'Data role tidak ditemukan'
            ], 404);
        }

        $role->delete();

        return response()->json([
            'success' => true,
            'message' => 'Role berhasil dihapus'
        ]);
    }
}