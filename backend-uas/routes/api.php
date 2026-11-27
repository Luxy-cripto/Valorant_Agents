<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\RoleController;
use App\Http\Controllers\Api\AgentPoolController;

/*
|--------------------------------------------------------------------------
| Public Routes (Autentikasi)
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

/*
|--------------------------------------------------------------------------
| Protected Routes (Wajib Mengirim Bearer Token & Terisolasi Per User)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    // Auth Status & Logout
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // CRUD Tabel 1: Roles (Tabel Induk)
    Route::apiResource('roles', RoleController::class);

    // CRUD Tabel 2: Agent Pools (Tabel Anak)
    Route::apiResource('agent-pools', AgentPoolController::class);
});