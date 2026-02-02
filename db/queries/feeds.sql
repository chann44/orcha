-- name: GetFeedByID :one
SELECT * FROM feeds
WHERE id = $1
LIMIT 1;

-- name: ListFeeds :many
SELECT * FROM feeds
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: GetFeedsByPublisherID :many
SELECT * FROM feeds
WHERE publisher_id = $1
ORDER BY created_at DESC;

-- name: CreateFeed :one
INSERT INTO feeds (
    id,
    publisher_id,
    name,
    description
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: UpdateFeed :one
UPDATE feeds
SET 
    name = $2,
    description = $3,
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteFeed :exec
DELETE FROM feeds
WHERE id = $1;

-- name: SearchFeedsByName :many
SELECT * FROM feeds
WHERE name ILIKE '%' || $1 || '%'
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: SearchFeedsByDescription :many
SELECT * FROM feeds
WHERE description ILIKE '%' || $1 || '%'
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountFeedsByPublisherID :one
SELECT COUNT(*) FROM feeds
WHERE publisher_id = $1;

-- name: GetFeedWithPublisher :one
SELECT 
    f.*,
    p.name as publisher_name,
    p.url as publisher_url,
    p.verified as publisher_verified,
    p.trust_score as publisher_trust_score
FROM feeds f
INNER JOIN publishers p ON f.publisher_id = p.id
WHERE f.id = $1
LIMIT 1;
