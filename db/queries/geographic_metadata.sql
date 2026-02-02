-- name: GetGeographicMetadataByEventID :one
SELECT * FROM geographic_metadata
WHERE event_id = $1
LIMIT 1;

-- name: GetGeographicMetadataByCountry :many
SELECT * FROM geographic_metadata
WHERE country = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetGeographicMetadataByScope :many
SELECT * FROM geographic_metadata
WHERE scope = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetGeographicMetadataByRegion :many
SELECT * FROM geographic_metadata
WHERE region = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CreateGeographicMetadata :one
INSERT INTO geographic_metadata (
    event_id,
    country,
    region,
    city,
    latitude,
    longitude,
    scope
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: UpdateGeographicMetadata :one
UPDATE geographic_metadata
SET 
    country = COALESCE($2, country),
    region = COALESCE($3, region),
    city = COALESCE($4, city),
    latitude = COALESCE($5, latitude),
    longitude = COALESCE($6, longitude),
    scope = COALESCE($7, scope)
WHERE event_id = $1
RETURNING *;

-- name: DeleteGeographicMetadata :exec
DELETE FROM geographic_metadata
WHERE event_id = $1;
