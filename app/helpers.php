<?php

declare(strict_types=1);

function json_response(array $payload, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function request_body(): array
{
    $raw = file_get_contents('php://input');
    if (!$raw) {
        return [];
    }

    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function bind_optional(PDOStatement $statement, array $params): void
{
    foreach ($params as $key => $value) {
        $type = is_int($value) ? PDO::PARAM_INT : PDO::PARAM_STR;
        $statement->bindValue($key, $value, $type);
    }
}

function current_user(): ?array
{
    return $_SESSION['user'] ?? null;
}

function require_login(): array
{
    $user = current_user();
    if (!$user) {
        json_response(['message' => 'Vui long dang nhap de tiep tuc.'], 401);
    }

    return $user;
}

function require_role(string $role): array
{
    $user = require_login();
    if (($user['role'] ?? null) !== $role) {
        json_response(['message' => 'Ban khong co quyen thuc hien thao tac nay.'], 403);
    }

    return $user;
}

function request_path(): string
{
    $path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
    return rtrim($path, '/') ?: '/';
}

function path_segments(): array
{
    return array_values(array_filter(explode('/', request_path()), static fn(string $part): bool => $part !== ''));
}

function query_string(string $key, ?string $fallback = null): ?string
{
    $value = $_GET[$key] ?? $fallback;
    return is_string($value) && $value !== '' ? trim($value) : $fallback;
}

function normalize_date(string $value, string $fallback): string
{
    $date = DateTime::createFromFormat('Y-m-d', $value);
    return $date && $date->format('Y-m-d') === $value ? $value : $fallback;
}


function csrf_token(): string
{
    if (empty($_SESSION['csrf_token'])) $_SESSION['csrf_token']=bin2hex(random_bytes(32));
    return $_SESSION['csrf_token'];
}
