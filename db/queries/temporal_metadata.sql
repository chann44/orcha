-- name: GetTemporalMetadataByEventID :one
SELECT * FROM temporal_metadata
WHERE event_id = $1
LIMIT 1;

-- name: GetTemporalMetadataByTimeSensitivity :many
SELECT * FROM temporal_metadata
WHERE time_sensitivity = $1
ORDER BY event_time DESC NULLS LAST
LIMIT $2 OFFSET $3;

-- name: GetTemporalMetadataByRelevanceDecay :many
SELECT * FROM temporal_metadata
WHERE relevance_decay = $1
ORDER BY event_time DESC NULLS LAST
LIMIT $2 OFFSET $3;

-- name: CreateTemporalMetadata :one
INSERT INTO temporal_metadata (
    event_id,
    event_time,
    relevance_decay,
    time_sensitivity
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: UpdateTemporalMetadata :one
UPDATE temporal_metadata
SET 
    event_time = COALESCE($2, event_time),
    relevance_decay = COALESCE($3, relevance_decay),
    time_sensitivity = COALESCE($4, time_sensitivity)
WHERE event_id = $1
RETURNING *;

-- name: DeleteTemporalMetadata :exec
DELETE FROM temporal_metadata
WHERE event_id = $1;
