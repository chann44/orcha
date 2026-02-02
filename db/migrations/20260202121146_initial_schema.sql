-- +goose Up
-- +goose StatementBegin

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Publishers table
CREATE TABLE publishers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    url TEXT,
    verified BOOLEAN NOT NULL DEFAULT false,
    trust_score DECIMAL(3,2) CHECK (trust_score >= 0 AND trust_score <= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Feeds table
CREATE TABLE feeds (
    id TEXT PRIMARY KEY,
    publisher_id TEXT NOT NULL REFERENCES publishers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Licenses table
CREATE TABLE licenses (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL CHECK (type IN ('open', 'research', 'commercial', 'training', 'enterprise')),
    name TEXT NOT NULL,
    terms_url TEXT NOT NULL,
    terms_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Events table
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    orcha_version TEXT NOT NULL DEFAULT '1.0',
    event_id UUID NOT NULL UNIQUE,
    feed_id TEXT NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
    published_at TIMESTAMPTZ NOT NULL,
    
    -- Source fields
    publisher_id TEXT NOT NULL REFERENCES publishers(id) ON DELETE CASCADE,
    
    -- Content fields
    content_type TEXT NOT NULL CHECK (content_type IN ('text', 'structured', 'binary')),
    title TEXT NOT NULL,
    summary TEXT NOT NULL,
    summary_tokens INTEGER NOT NULL,
    body TEXT,
    body_tokens INTEGER,
    language TEXT NOT NULL DEFAULT 'en',
    content_hash TEXT NOT NULL,
    
    -- Semantic fields
    event_type TEXT,
    topics TEXT[],
    sentiment DECIMAL(3,2) CHECK (sentiment >= -1 AND sentiment <= 1),
    importance DECIMAL(3,2) CHECK (importance >= 0 AND importance <= 1),
    
    -- License reference
    license_id TEXT NOT NULL REFERENCES licenses(id) ON DELETE RESTRICT,
    
    -- Provenance fields
    original_url TEXT,
    original_published TIMESTAMPTZ,
    captured_at TIMESTAMPTZ,
    processed_at TIMESTAMPTZ,
    processing_model TEXT,
    extraction_confidence DECIMAL(3,2) CHECK (extraction_confidence >= 0 AND extraction_confidence <= 1),
    
    -- Relations
    replaces_event_id UUID REFERENCES events(event_id) ON DELETE SET NULL,
    thread_id UUID,
    parent_event_id UUID REFERENCES events(event_id) ON DELETE SET NULL,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT body_tokens_required CHECK (
        (body IS NULL AND body_tokens IS NULL) OR 
        (body IS NOT NULL AND body_tokens IS NOT NULL)
    )
);

-- Entities table (from semantic layer)
CREATE TABLE entities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('company', 'person', 'investor', 'product', 'location', 'organization', 'technology', 'regulation')),
    role TEXT,
    confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Entity identifiers table
CREATE TABLE entity_identifiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    identifier_type TEXT NOT NULL,
    identifier_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(entity_id, identifier_type, identifier_value)
);

-- Entity attributes table (flexible key-value store)
CREATE TABLE entity_attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    attribute_key TEXT NOT NULL,
    attribute_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(entity_id, attribute_key)
);

-- Metrics table (from semantic layer)
CREATE TABLE metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    value NUMERIC,
    value_text TEXT,
    unit TEXT,
    confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
    context TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT value_or_text CHECK (value IS NOT NULL OR value_text IS NOT NULL)
);

-- Temporal metadata table
CREATE TABLE temporal_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    event_time TIMESTAMPTZ,
    relevance_decay TEXT CHECK (relevance_decay IN ('none', 'slow', 'medium', 'fast')),
    time_sensitivity TEXT CHECK (time_sensitivity IN ('realtime', 'minutes', 'hours', 'days', 'weeks', 'none')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(event_id)
);

-- Geographic metadata table
CREATE TABLE geographic_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    country TEXT,
    region TEXT,
    city TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    scope TEXT CHECK (scope IN ('local', 'regional', 'national', 'international', 'global')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(event_id)
);

-- Affordances table
CREATE TABLE affordances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    action_id TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('lookup', 'subscribe', 'related', 'custom')),
    name TEXT NOT NULL,
    description TEXT,
    endpoint TEXT NOT NULL,
    method TEXT NOT NULL CHECK (method IN ('GET', 'POST', 'PUT', 'PATCH', 'DELETE')),
    cost_cents INTEGER,
    response_tokens_estimate INTEGER,
    parameters JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Subscriptions table
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feed_id TEXT NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
    consumer_id TEXT NOT NULL,
    delivery_method TEXT NOT NULL CHECK (delivery_method IN ('webhook', 'polling', 'websocket')),
    webhook_url TEXT,
    webhook_secret TEXT,
    filters JSONB,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT webhook_required CHECK (
        (delivery_method != 'webhook') OR 
        (delivery_method = 'webhook' AND webhook_url IS NOT NULL)
    )
);

-- License agreements table
CREATE TABLE license_agreements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    license_id TEXT NOT NULL REFERENCES licenses(id) ON DELETE RESTRICT,
    consumer_id TEXT NOT NULL,
    organization_id TEXT,
    authorized_signer TEXT,
    terms_hash TEXT NOT NULL,
    agreed_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'revoked', 'expired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Related events junction table
CREATE TABLE related_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    related_event_id UUID NOT NULL REFERENCES events(event_id) ON DELETE CASCADE,
    relation_type TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(event_id, related_event_id),
    CHECK (event_id != related_event_id)
);

-- Indexes for performance
CREATE INDEX idx_events_feed_id ON events(feed_id);
CREATE INDEX idx_events_published_at ON events(published_at DESC);
CREATE INDEX idx_events_event_type ON events(event_type);
CREATE INDEX idx_events_importance ON events(importance DESC);
CREATE INDEX idx_events_license_id ON events(license_id);
CREATE INDEX idx_events_publisher_id ON events(publisher_id);
CREATE INDEX idx_events_topics ON events USING GIN(topics);

CREATE INDEX idx_entities_event_id ON entities(event_id);
CREATE INDEX idx_entities_type ON entities(type);
CREATE INDEX idx_entities_name ON entities(name);

CREATE INDEX idx_entity_identifiers_entity_id ON entity_identifiers(entity_id);
CREATE INDEX idx_entity_identifiers_value ON entity_identifiers(identifier_type, identifier_value);

CREATE INDEX idx_metrics_event_id ON metrics(event_id);
CREATE INDEX idx_metrics_name ON metrics(name);

CREATE INDEX idx_subscriptions_feed_id ON subscriptions(feed_id);
CREATE INDEX idx_subscriptions_consumer_id ON subscriptions(consumer_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

CREATE INDEX idx_license_agreements_license_id ON license_agreements(license_id);
CREATE INDEX idx_license_agreements_consumer_id ON license_agreements(consumer_id);
CREATE INDEX idx_license_agreements_status ON license_agreements(status);

CREATE INDEX idx_related_events_event_id ON related_events(event_id);
CREATE INDEX idx_related_events_related_event_id ON related_events(related_event_id);

-- Full-text search indexes
CREATE INDEX idx_events_title_search ON events USING GIN(to_tsvector('english', title));
CREATE INDEX idx_events_summary_search ON events USING GIN(to_tsvector('english', summary));
CREATE INDEX idx_events_body_search ON events USING GIN(to_tsvector('english', body)) WHERE body IS NOT NULL;

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

-- Drop indexes
DROP INDEX IF EXISTS idx_events_body_search;
DROP INDEX IF EXISTS idx_events_summary_search;
DROP INDEX IF EXISTS idx_events_title_search;
DROP INDEX IF EXISTS idx_related_events_related_event_id;
DROP INDEX IF EXISTS idx_related_events_event_id;
DROP INDEX IF EXISTS idx_license_agreements_status;
DROP INDEX IF EXISTS idx_license_agreements_consumer_id;
DROP INDEX IF EXISTS idx_license_agreements_license_id;
DROP INDEX IF EXISTS idx_subscriptions_status;
DROP INDEX IF EXISTS idx_subscriptions_consumer_id;
DROP INDEX IF EXISTS idx_subscriptions_feed_id;
DROP INDEX IF EXISTS idx_metrics_name;
DROP INDEX IF EXISTS idx_metrics_event_id;
DROP INDEX IF EXISTS idx_entity_identifiers_value;
DROP INDEX IF EXISTS idx_entity_identifiers_entity_id;
DROP INDEX IF EXISTS idx_entities_name;
DROP INDEX IF EXISTS idx_entities_type;
DROP INDEX IF EXISTS idx_entities_event_id;
DROP INDEX IF EXISTS idx_events_topics;
DROP INDEX IF EXISTS idx_events_publisher_id;
DROP INDEX IF EXISTS idx_events_license_id;
DROP INDEX IF EXISTS idx_events_importance;
DROP INDEX IF EXISTS idx_events_event_type;
DROP INDEX IF EXISTS idx_events_published_at;
DROP INDEX IF EXISTS idx_events_feed_id;

-- Drop tables in reverse order of dependencies
DROP TABLE IF EXISTS related_events;
DROP TABLE IF EXISTS license_agreements;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS affordances;
DROP TABLE IF EXISTS geographic_metadata;
DROP TABLE IF EXISTS temporal_metadata;
DROP TABLE IF EXISTS metrics;
DROP TABLE IF EXISTS entity_attributes;
DROP TABLE IF EXISTS entity_identifiers;
DROP TABLE IF EXISTS entities;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS licenses;
DROP TABLE IF EXISTS feeds;
DROP TABLE IF EXISTS publishers;

-- +goose StatementEnd
