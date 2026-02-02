-- name: SearchEventsAdvanced :many
SELECT * FROM events
WHERE 
    ($1::TEXT IS NULL OR feed_id = $1)
    AND ($2::TEXT IS NULL OR event_type = $2)
    AND ($3::TEXT[] IS NULL OR topics && $3::TEXT[])
    AND ($4::DECIMAL IS NULL OR importance >= $4)
    AND ($5::TIMESTAMPTZ IS NULL OR published_at >= $5)
    AND ($6::TIMESTAMPTZ IS NULL OR published_at <= $6)
    AND ($7::TEXT IS NULL OR publisher_id = $7)
    AND ($8::TEXT IS NULL OR language = $8)
ORDER BY published_at DESC
LIMIT $9 OFFSET $10;

-- name: GetEventsWithEntities :many
SELECT 
    e.*,
    json_agg(
        json_build_object(
            'id', ent.id,
            'name', ent.name,
            'type', ent.type,
            'role', ent.role,
            'confidence', ent.confidence
        )
    ) FILTER (WHERE ent.id IS NOT NULL) as entities
FROM events e
LEFT JOIN entities ent ON e.event_id = ent.event_id
WHERE e.feed_id = $1
GROUP BY e.id, e.orcha_version, e.event_id, e.feed_id, e.published_at, e.publisher_id, 
         e.content_type, e.title, e.summary, e.summary_tokens, e.body, e.body_tokens, 
         e.language, e.content_hash, e.event_type, e.topics, e.sentiment, e.importance,
         e.license_id, e.original_url, e.original_published, e.captured_at, e.processed_at,
         e.processing_model, e.extraction_confidence, e.replaces_event_id, e.thread_id,
         e.parent_event_id, e.created_at, e.updated_at
ORDER BY e.published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventsWithMetrics :many
SELECT 
    e.*,
    json_agg(
        json_build_object(
            'id', m.id,
            'name', m.name,
            'value', m.value,
            'value_text', m.value_text,
            'unit', m.unit,
            'confidence', m.confidence
        )
    ) FILTER (WHERE m.id IS NOT NULL) as metrics
FROM events e
LEFT JOIN metrics m ON e.event_id = m.event_id
WHERE e.feed_id = $1
GROUP BY e.id, e.orcha_version, e.event_id, e.feed_id, e.published_at, e.publisher_id,
         e.content_type, e.title, e.summary, e.summary_tokens, e.body, e.body_tokens,
         e.language, e.content_hash, e.event_type, e.topics, e.sentiment, e.importance,
         e.license_id, e.original_url, e.original_published, e.captured_at, e.processed_at,
         e.processing_model, e.extraction_confidence, e.replaces_event_id, e.thread_id,
         e.parent_event_id, e.created_at, e.updated_at
ORDER BY e.published_at DESC
LIMIT $2 OFFSET $3;

-- name: GetEventWithFullDetails :one
SELECT 
    e.*,
    json_build_object(
        'id', p.id,
        'name', p.name,
        'url', p.url,
        'verified', p.verified,
        'trust_score', p.trust_score
    ) as publisher,
    json_build_object(
        'id', l.id,
        'type', l.type,
        'name', l.name,
        'terms_url', l.terms_url
    ) as license,
    (
        SELECT json_agg(
            json_build_object(
                'id', ent.id,
                'name', ent.name,
                'type', ent.type,
                'role', ent.role
            )
        )
        FROM entities ent
        WHERE ent.event_id = e.event_id
    ) as entities,
    (
        SELECT json_agg(
            json_build_object(
                'id', m.id,
                'name', m.name,
                'value', m.value,
                'value_text', m.value_text,
                'unit', m.unit
            )
        )
        FROM metrics m
        WHERE m.event_id = e.event_id
    ) as metrics,
    (
        SELECT json_build_object(
            'event_time', tm.event_time,
            'relevance_decay', tm.relevance_decay,
            'time_sensitivity', tm.time_sensitivity
        )
        FROM temporal_metadata tm
        WHERE tm.event_id = e.event_id
    ) as temporal,
    (
        SELECT json_build_object(
            'country', gm.country,
            'region', gm.region,
            'city', gm.city,
            'scope', gm.scope
        )
        FROM geographic_metadata gm
        WHERE gm.event_id = e.event_id
    ) as geographic
FROM events e
INNER JOIN publishers p ON e.publisher_id = p.id
INNER JOIN licenses l ON e.license_id = l.id
WHERE e.event_id = $1
LIMIT 1;
