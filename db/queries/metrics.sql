-- name: GetMetricByID :one
SELECT * FROM metrics
WHERE id = $1
LIMIT 1;

-- name: GetMetricsByEventID :many
SELECT * FROM metrics
WHERE event_id = $1
ORDER BY name, created_at;

-- name: GetMetricsByName :many
SELECT * FROM metrics
WHERE name = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetMetricsByEventIDAndName :many
SELECT * FROM metrics
WHERE event_id = $1 AND name = $2
ORDER BY created_at DESC;

-- name: CreateMetric :one
INSERT INTO metrics (
    event_id,
    name,
    value,
    value_text,
    unit,
    confidence,
    context
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: UpdateMetric :one
UPDATE metrics
SET 
    value = COALESCE($2, value),
    value_text = COALESCE($3, value_text),
    unit = COALESCE($4, unit),
    confidence = COALESCE($5, confidence),
    context = COALESCE($6, context)
WHERE id = $1
RETURNING *;

-- name: DeleteMetric :exec
DELETE FROM metrics
WHERE id = $1;

-- name: DeleteMetricsByEventID :exec
DELETE FROM metrics
WHERE event_id = $1;
