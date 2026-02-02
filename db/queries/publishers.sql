-- name: GetPublisherByID :one
SELECT * FROM publishers
WHERE id = $1
LIMIT 1;

-- name: ListPublishers :many
SELECT * FROM publishers
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: GetVerifiedPublishers :many
SELECT * FROM publishers
WHERE verified = true
ORDER BY trust_score DESC NULLS LAST, created_at DESC;

-- name: GetPublishersByTrustScore :many
SELECT * FROM publishers
WHERE trust_score >= $1
ORDER BY trust_score DESC, created_at DESC
LIMIT $2 OFFSET $3;

-- name: CreatePublisher :one
INSERT INTO publishers (
    id,
    name,
    url,
    verified,
    trust_score
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: UpdatePublisher :one
UPDATE publishers
SET 
    name = COALESCE($2, name),
    url = COALESCE($3, url),
    verified = COALESCE($4, verified),
    trust_score = COALESCE($5, trust_score),
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeletePublisher :exec
DELETE FROM publishers
WHERE id = $1;

-- name: UpdatePublisherTrustScore :one
UPDATE publishers
SET 
    trust_score = $2,
    updated_at = NOW()
WHERE id = $1
RETURNING *;
