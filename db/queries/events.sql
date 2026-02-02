-- name: GetEventByID :one
SELECT * FROM events
WHERE event_id = $1
LIMIT 1;

-- name: GetEventsByFeedID :many
SELECT * FROM events
WHERE feed_id = $1
ORDER BY published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventsByFeedIDSince :many
SELECT * FROM events
WHERE feed_id = $1
  AND published_at >= $2
ORDER BY published_at DESC
LIMIT $3;

-- name: GetEventsByFeedIDUntil :many
SELECT * FROM events
WHERE feed_id = $1
  AND published_at <= $2
ORDER BY published_at DESC
LIMIT $3;

-- name: GetEventsByFeedIDDateRange :many
SELECT * FROM events
WHERE feed_id = $1
  AND published_at >= $2
  AND published_at <= $3
ORDER BY published_at DESC
LIMIT $4 OFFSET $5;

-- name: GetEventsByType :many
SELECT * FROM events
WHERE event_type = $1
ORDER BY published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventsByMinImportance :many
SELECT * FROM events
WHERE importance >= $1
ORDER BY importance DESC, published_at DESC
LIMIT $2 OFFSET $3;

-- name: CreateEvent :one
INSERT INTO events (
    orcha_version,
    event_id,
    feed_id,
    published_at,
    publisher_id,
    content_type,
    title,
    summary,
    summary_tokens,
    body,
    body_tokens,
    language,
    content_hash,
    event_type,
    topics,
    sentiment,
    importance,
    license_id,
    original_url,
    original_published,
    captured_at,
    processed_at,
    processing_model,
    extraction_confidence
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24
) RETURNING *;

-- name: UpdateEvent :one
UPDATE events
SET 
    updated_at = NOW()
WHERE event_id = $1
RETURNING *;

-- name: DeleteEvent :exec
DELETE FROM events
WHERE event_id = $1;

-- name: SearchEventsByTopic :many
SELECT * FROM events
WHERE $1 = ANY(topics)
ORDER BY published_at DESC
LIMIT $2 OFFSET $3;

-- name: SearchEventsByTopics :many
SELECT * FROM events
WHERE topics && $1::TEXT[]
ORDER BY published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventsByPublisherID :many
SELECT * FROM events
WHERE publisher_id = $1
ORDER BY published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventsByLicenseID :many
SELECT * FROM events
WHERE license_id = $1
ORDER BY published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventsByDateRange :many
SELECT * FROM events
WHERE published_at >= $1 AND published_at <= $2
ORDER BY published_at DESC
LIMIT $3 OFFSET $4;

-- name: GetEventsByTypeAndImportance :many
SELECT * FROM events
WHERE event_type = $1 AND importance >= $2
ORDER BY importance DESC, published_at DESC
LIMIT $3 OFFSET $4;

-- name: FullTextSearchEvents :many
SELECT * FROM events
WHERE 
    to_tsvector('english', title || ' ' || COALESCE(summary, '') || ' ' || COALESCE(body, '')) @@ plainto_tsquery('english', $1)
ORDER BY 
    ts_rank(to_tsvector('english', title || ' ' || COALESCE(summary, '') || ' ' || COALESCE(body, '')), plainto_tsquery('english', $1)) DESC,
    published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetRecentEvents :many
SELECT * FROM events
ORDER BY published_at DESC
LIMIT $1 OFFSET $2;

-- name: GetEventsByLanguage :many
SELECT * FROM events
WHERE language = $1
ORDER BY published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventsByContentType :many
SELECT * FROM events
WHERE content_type = $1
ORDER BY published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventsRelatedToEventID :many
SELECT e.* FROM events e
INNER JOIN related_events re ON e.event_id = re.related_event_id
WHERE re.event_id = $1
ORDER BY e.published_at DESC;

-- name: CountEventsByFeedID :one
SELECT COUNT(*) FROM events
WHERE feed_id = $1;

-- name: CountEventsByPublisherID :one
SELECT COUNT(*) FROM events
WHERE publisher_id = $1;
