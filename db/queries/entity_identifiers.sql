-- name: GetEntityIdentifierByID :one
SELECT * FROM entity_identifiers
WHERE id = $1
LIMIT 1;

-- name: GetEntityIdentifiersByEntityID :many
SELECT * FROM entity_identifiers
WHERE entity_id = $1
ORDER BY identifier_type;

-- name: GetEntityIdentifierByTypeAndValue :one
SELECT * FROM entity_identifiers
WHERE identifier_type = $1 AND identifier_value = $2
LIMIT 1;

-- name: CreateEntityIdentifier :one
INSERT INTO entity_identifiers (
    entity_id,
    identifier_type,
    identifier_value
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: UpdateEntityIdentifier :one
UPDATE entity_identifiers
SET 
    identifier_value = $3
WHERE entity_id = $1 AND identifier_type = $2
RETURNING *;

-- name: DeleteEntityIdentifier :exec
DELETE FROM entity_identifiers
WHERE id = $1;

-- name: DeleteEntityIdentifiersByEntityID :exec
DELETE FROM entity_identifiers
WHERE entity_id = $1;
