-- name: GetLicenseAgreementByID :one
SELECT * FROM license_agreements
WHERE id = $1
LIMIT 1;

-- name: GetLicenseAgreementsByLicenseID :many
SELECT * FROM license_agreements
WHERE license_id = $1
ORDER BY agreed_at DESC;

-- name: GetLicenseAgreementsByConsumerID :many
SELECT * FROM license_agreements
WHERE consumer_id = $1
ORDER BY agreed_at DESC;

-- name: GetActiveLicenseAgreements :many
SELECT * FROM license_agreements
WHERE status = 'active'
ORDER BY agreed_at DESC
LIMIT $1 OFFSET $2;

-- name: GetLicenseAgreementByConsumerAndLicense :one
SELECT * FROM license_agreements
WHERE consumer_id = $1 AND license_id = $2 AND status = 'active'
ORDER BY agreed_at DESC
LIMIT 1;

-- name: CreateLicenseAgreement :one
INSERT INTO license_agreements (
    license_id,
    consumer_id,
    organization_id,
    authorized_signer,
    terms_hash,
    agreed_at,
    status
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: UpdateLicenseAgreement :one
UPDATE license_agreements
SET 
    organization_id = COALESCE($2, organization_id),
    authorized_signer = COALESCE($3, authorized_signer),
    status = COALESCE($4, status),
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: RevokeLicenseAgreement :one
UPDATE license_agreements
SET 
    status = 'revoked',
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteLicenseAgreement :exec
DELETE FROM license_agreements
WHERE id = $1;
