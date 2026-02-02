-- name: GetSubscriptionByID :one
SELECT * FROM subscriptions
WHERE id = $1
LIMIT 1;

-- name: ListSubscriptions :many
SELECT * FROM subscriptions
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: GetSubscriptionsByFeedID :many
SELECT * FROM subscriptions
WHERE feed_id = $1
ORDER BY created_at DESC;

-- name: GetSubscriptionsByConsumerID :many
SELECT * FROM subscriptions
WHERE consumer_id = $1
ORDER BY created_at DESC;

-- name: GetActiveSubscriptions :many
SELECT * FROM subscriptions
WHERE status = 'active'
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: GetSubscriptionsByDeliveryMethod :many
SELECT * FROM subscriptions
WHERE delivery_method = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetSubscriptionsByStatus :many
SELECT * FROM subscriptions
WHERE status = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: CreateSubscription :one
INSERT INTO subscriptions (
    feed_id,
    consumer_id,
    delivery_method,
    webhook_url,
    webhook_secret,
    filters,
    status
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: UpdateSubscription :one
UPDATE subscriptions
SET 
    delivery_method = COALESCE($2, delivery_method),
    webhook_url = COALESCE($3, webhook_url),
    webhook_secret = COALESCE($4, webhook_secret),
    filters = COALESCE($5, filters),
    status = COALESCE($6, status),
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: UpdateSubscriptionStatus :one
UPDATE subscriptions
SET 
    status = $2,
    updated_at = NOW()
WHERE id = $1
RETURNING *;

-- name: DeleteSubscription :exec
DELETE FROM subscriptions
WHERE id = $1;

-- name: DeleteSubscriptionsByFeedID :exec
DELETE FROM subscriptions
WHERE feed_id = $1;
