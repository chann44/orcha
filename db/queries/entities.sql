-- name: GetEntityByID :one
SELECT * FROM entities
WHERE id = $1
LIMIT 1;

-- name: GetEntitiesByEventID :many
SELECT * FROM entities
WHERE event_id = $1
ORDER BY confidence DESC NULLS LAST, created_at;

-- name: GetEntitiesByType :many
SELECT * FROM entities
WHERE type = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEntitiesByRole :many
SELECT * FROM entities
WHERE role = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: SearchEntitiesByName :many
SELECT * FROM entities
WHERE name ILIKE '%' || $1 || '%'
ORDER BY name
LIMIT $2 OFFSET $3;

-- name: GetEntitiesByEventIDAndType :many
SELECT * FROM entities
WHERE event_id = $1 AND type = $2
ORDER BY confidence DESC NULLS LAST;

-- name: CreateEntity :one
INSERT INTO entities (
    event_id,
    name,
    type,
    role,
    confidence
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: UpdateEntity :one
UPDATE entities
SET 
    name = COALESCE($2, name),
    type = COALESCE($3, type),
    role = COALESCE($4, role),
    confidence = COALESCE($5, confidence)
WHERE id = $1
RETURNING *;

-- name: DeleteEntity :exec
DELETE FROM entities
WHERE id = $1;

-- name: DeleteEntitiesByEventID :exec
DELETE FROM entities
WHERE event_id = $1;
