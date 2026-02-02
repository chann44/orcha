-- name: GetLicenseByID :one
SELECT * FROM licenses
WHERE id = $1
LIMIT 1;

-- name: ListLicenses :many
SELECT * FROM licenses
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: GetLicensesByType :many
SELECT * FROM licenses
WHERE type = $1
ORDER BY created_at DESC;

-- name: CreateLicense :one
INSERT INTO licenses (
    id,
    type,
    name,
    terms_url,
    terms_hash
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: UpdateLicense :one
UPDATE licenses
SET 
    name = COALESCE($2, name),
    terms_url = COALESCE($3, terms_url),
    terms_hash = COALESCE($4, terms_hash),
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteLicense :exec
DELETE FROM licenses
WHERE id = $1;
