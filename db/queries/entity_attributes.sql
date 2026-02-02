-- name: GetEntityAttributeByID :one
SELECT * FROM entity_attributes
WHERE id = $1
LIMIT 1;

-- name: GetEntityAttributesByEntityID :many
SELECT * FROM entity_attributes
WHERE entity_id = $1
ORDER BY attribute_key;

-- name: GetEntityAttributeByKey :one
SELECT * FROM entity_attributes
WHERE entity_id = $1 AND attribute_key = $2
LIMIT 1;

-- name: CreateEntityAttribute :one
INSERT INTO entity_attributes (
    entity_id,
    attribute_key,
    attribute_value
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: UpdateEntityAttribute :one
UPDATE entity_attributes
SET 
    attribute_value = $3
WHERE entity_id = $1 AND attribute_key = $2
RETURNING *;

-- name: DeleteEntityAttribute :exec
DELETE FROM entity_attributes
WHERE id = $1;

-- name: DeleteEntityAttributesByEntityID :exec
DELETE FROM entity_attributes
WHERE entity_id = $1;
