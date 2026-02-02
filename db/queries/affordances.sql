-- name: GetAffordanceByID :one
SELECT * FROM affordances
WHERE id = $1
LIMIT 1;

-- name: GetAffordancesByEventID :many
SELECT * FROM affordances
WHERE event_id = $1
ORDER BY created_at;

-- name: GetAffordancesByType :many
SELECT * FROM affordances
WHERE type = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetAffordancesByMethod :many
SELECT * FROM affordances
WHERE method = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CreateAffordance :one
INSERT INTO affordances (
    event_id,
    action_id,
    type,
    name,
    description,
    endpoint,
    method,
    cost_cents,
    response_tokens_estimate,
    parameters
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
) RETURNING *;

-- name: UpdateAffordance :one
UPDATE affordances
SET 
    name = COALESCE($3, name),
    description = COALESCE($4, description),
    endpoint = COALESCE($5, endpoint),
    method = COALESCE($6, method),
    cost_cents = COALESCE($7, cost_cents),
    response_tokens_estimate = COALESCE($8, response_tokens_estimate),
    parameters = COALESCE($9, parameters)
WHERE id = $1 AND event_id = $2
RETURNING *;

-- name: DeleteAffordance :exec
DELETE FROM affordances
WHERE id = $1;

-- name: DeleteAffordancesByEventID :exec
DELETE FROM affordances
WHERE event_id = $1;
