-- name: GetRelatedEventByID :one
SELECT * FROM related_events
WHERE id = $1
LIMIT 1;

-- name: GetRelatedEventsByEventID :many
SELECT * FROM related_events
WHERE event_id = $1
ORDER BY created_at;

-- name: GetRelatedEventsByRelatedEventID :many
SELECT * FROM related_events
WHERE related_event_id = $1
ORDER BY created_at;

-- name: GetRelatedEventsByRelationType :many
SELECT * FROM related_events
WHERE relation_type = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CreateRelatedEvent :one
INSERT INTO related_events (
    event_id,
    related_event_id,
    relation_type
) VALUES (
    $1, $2, $3
) RETURNING *;

-- name: DeleteRelatedEvent :exec
DELETE FROM related_events
WHERE id = $1;

-- name: DeleteRelatedEventsByEventID :exec
DELETE FROM related_events
WHERE event_id = $1;

-- name: DeleteRelatedEventsByRelatedEventID :exec
DELETE FROM related_events
WHERE related_event_id = $1;

-- name: DeleteRelatedEventPair :exec
DELETE FROM related_events
WHERE event_id = $1 AND related_event_id = $2;
