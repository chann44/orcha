# OrchaProtocol Specification

```
RFC: Orcha-001
Title: OrchaProtocol Specification v1.0
Status: Draft
Category: Standards Track
Author: [Your Name]
Created: 2025-01-21
Updated: 2025-01-21
```

---

## Abstract

This document specifies Orcha, an open protocol for publishing and consuming structured data feeds optimized for AI agent consumption. Orchadefines a standard event format, semantic metadata schema, licensing framework, and transport mechanisms that enable AI agents to discover, subscribe to, and legally consume data from diverse sources.

The protocol addresses three key challenges in the emerging AI agent ecosystem: (1) lack of standardized, machine-optimized data formats, (2) absence of clear content licensing mechanisms for AI consumption, and (3) no unified discovery and subscription model for agent data sources.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Terminology](#2-terminology)
3. [Protocol Overview](#3-protocol-overview)
4. [Event Schema](#4-event-schema)
5. [Semantic Layer](#5-semantic-layer)
6. [Licensing Framework](#6-licensing-framework)
7. [Transport Mechanisms](#7-transport-mechanisms)
8. [Discovery and Subscription](#8-discovery-and-subscription)
9. [Security Considerations](#9-security-considerations)
10. [Implementation Requirements](#10-implementation-requirements)
11. [Extension Mechanisms](#11-extension-mechanisms)
12. [IANA Considerations](#12-iana-considerations)
13. [References](#13-references)
14. [Appendices](#14-appendices)

---

## 1. Introduction

### 1.1 Background

The proliferation of AI agents—autonomous software systems that perceive, reason, and act on behalf of users—has created an urgent need for structured data infrastructure. Current data distribution mechanisms (RSS, REST APIs, webhooks) were designed for human consumption or traditional software integration. They lack the semantic richness, licensing clarity, and agent-specific optimizations required for effective AI agent operation.

### 1.2 Problem Statement

AI agents face several challenges when consuming external data:

1. **Format Fragmentation**: Data sources use inconsistent formats, requiring custom parsing logic for each source.

2. **Semantic Poverty**: Raw data lacks the contextual metadata agents need for effective reasoning.

3. **Licensing Ambiguity**: No standard mechanism exists for content owners to specify how AI systems may use their data, creating legal uncertainty.

4. **Discovery Difficulty**: Agents cannot programmatically discover relevant data sources based on intent or capability.

5. **Token Inefficiency**: Existing formats waste context window budget on markup, boilerplate, and irrelevant content.

### 1.3 Design Goals

Orchais designed with the following goals:

- **Simplicity**: Easy to implement for both publishers and consumers
- **Semantic Richness**: Structured metadata that enables agent reasoning
- **Legal Clarity**: Built-in licensing that protects publishers and consumers
- **Token Efficiency**: Optimized for LLM context window constraints
- **Extensibility**: Support for domain-specific extensions
- **Interoperability**: Compatible with existing infrastructure and protocols

### 1.4 Scope

This specification defines:

- The Orchaevent schema and required fields
- Semantic metadata vocabulary and typing system
- Licensing framework and rights expression
- Transport bindings (HTTP, WebSocket, webhooks)
- Discovery and subscription mechanisms

This specification does not define:

- Specific processing or enrichment algorithms
- Billing or payment mechanisms (implementation-specific)
- Agent behavior or consumption patterns
- Content moderation policies

### 1.5 Notational Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

---

## 2. Terminology

**Agent**: An autonomous software system that consumes data, performs reasoning, and takes actions on behalf of users or other systems.

**Event**: A discrete unit of information published to an Orchafeed, conforming to the schema defined in Section 4.

**Feed**: A named, ordered collection of events from a single publisher, identified by a unique feed ID.

**Publisher**: An entity that creates and distributes events through Orchafeeds.

**Consumer**: An entity (typically an AI agent or agent framework) that subscribes to and processes Orchaevents.

**License**: A machine-readable declaration of permissions, requirements, and restrictions governing how consumers may use event content.

**Affordance**: A declared action or capability that an agent can perform in response to an event.

**Semantic Type**: A standardized classification of event content that enables cross-feed interoperability.

**Token Budget**: The context window capacity an agent has available for processing content, measured in tokens.

---

## 3. Protocol Overview

### 3.1 Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          OrchaECOSYSTEM                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   PUBLISHERS                    INFRASTRUCTURE                CONSUMERS  │
│   ──────────                    ──────────────                ─────────  │
│                                                                          │
│   ┌─────────┐                  ┌─────────────┐              ┌─────────┐ │
│   │ Content │                  │  Orcha │              │  AI     │ │
│   │ Source  │───publish───────▶│   Server    │◀──subscribe──│  Agent  │ │
│   └─────────┘                  └─────────────┘              └─────────┘ │
│                                      │                                   │
│   ┌─────────┐                        │                      ┌─────────┐ │
│   │ Content │───publish──────────────┤                      │  Agent  │ │
│   │ Source  │                        │◀──────subscribe──────│Framework│ │
│   └─────────┘                        │                      └─────────┘ │
│                                      │                                   │
│                               ┌──────▼──────┐                           │
│                               │  Registry   │                           │
│                               │ (Discovery) │                           │
│                               └─────────────┘                           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Data Flow

1. **Publication**: Publishers create events conforming to the Orchaschema and submit them to an Orchaserver.

2. **Processing**: The server validates, enriches (optionally), and stores events.

3. **Discovery**: Consumers query the registry to find feeds matching their intent.

4. **Subscription**: Consumers subscribe to feeds via pull (polling), push (webhooks), or streaming (WebSocket/SSE).

5. **Licensing**: Before consuming events, consumers agree to the feed's license terms.

6. **Consumption**: Consumers receive events with full semantic metadata and licensing information.

7. **Action**: Consumers may invoke affordances declared in events to perform follow-up actions.

### 3.3 Conformance Levels

**OrchaCore**: Minimum implementation supporting event schema, basic transport, and licensing.

**OrchaExtended**: Full implementation including semantic search, streaming, webhooks, and advanced licensing.

**OrchaRegistry**: Implementation that provides feed discovery and subscription management.

---

## 4. Event Schema

### 4.1 Overview

An Orchaevent is a JSON object containing content, metadata, semantic annotations, licensing information, and optional affordances. Events are immutable once published; updates are represented as new events with references to previous versions.

### 4.2 Required Fields

Every Orchaevent MUST include the following fields:

```json
{
  "orcha_version": "1.0",
  "event_id": "<uuid>",
  "feed_id": "<string>",
  "published_at": "<iso8601-datetime>",
  "content": { ... },
  "license": { ... }
}
```

### 4.3 Complete Event Schema

```json
{
  "$schema": "https://orcha.io/schema/event/v1.0",
  
  "orcha_version": "1.0",
  
  "event_id": "019abc12-3def-7890-abcd-ef1234567890",
  
  "feed_id": "fintech-funding-rounds",
  
  "published_at": "2025-01-21T10:30:00Z",
  
  "source": {
    "publisher_id": "pub_techcrunch",
    "publisher_name": "TechCrunch",
    "publisher_url": "https://techcrunch.com",
    "verified": true,
    "trust_score": 0.95
  },
  
  "content": {
    "type": "text",
    "title": "Stripe raises $6.5B Series I at $50B valuation",
    "summary": "Payments giant Stripe closed $6.5B Series I funding round led by Sequoia, valuing the company at $50B, with plans to expand into crypto payments.",
    "summary_tokens": 32,
    "body": "<full article text>",
    "body_tokens": 847,
    "language": "en",
    "content_hash": "sha256:abc123..."
  },
  
  "semantic": {
    "event_type": "funding_round",
    "entities": [
      {
        "name": "Stripe",
        "type": "company",
        "role": "subject",
        "identifiers": {
          "orcha": "ent_stripe_inc",
          "crunchbase": "stripe",
          "linkedin": "company/stripe"
        },
        "attributes": {
          "industry": "fintech",
          "founded": "2010",
          "headquarters": "San Francisco, CA"
        }
      },
      {
        "name": "Sequoia Capital",
        "type": "investor",
        "role": "lead_investor",
        "identifiers": {
          "orcha": "ent_sequoia",
          "crunchbase": "sequoia-capital"
        }
      }
    ],
    "topics": ["fintech", "payments", "venture-capital", "crypto"],
    "metrics": [
      {"name": "funding_amount", "value": 6500000000, "unit": "USD"},
      {"name": "valuation", "value": 50000000000, "unit": "USD"},
      {"name": "funding_round", "value": "Series I", "unit": null}
    ],
    "sentiment": 0.7,
    "importance": 0.92,
    "temporal": {
      "event_time": "2025-01-21T09:00:00Z",
      "relevance_decay": "slow",
      "time_sensitivity": "hours"
    },
    "geography": {
      "primary": {"country": "US", "region": "California", "city": "San Francisco"},
      "scope": "global"
    }
  },
  
  "affordances": [
    {
      "action_id": "aff_001",
      "type": "lookup",
      "name": "Get Company Profile",
      "description": "Retrieve full company profile for Stripe",
      "endpoint": "/api/v1/entities/ent_stripe_inc",
      "method": "GET",
      "cost_cents": 5,
      "response_tokens_estimate": 2000
    },
    {
      "action_id": "aff_002",
      "type": "subscribe",
      "name": "Follow Company",
      "description": "Subscribe to all events about Stripe",
      "endpoint": "/api/v1/subscriptions",
      "method": "POST",
      "parameters": {
        "entity_id": "ent_stripe_inc"
      }
    },
    {
      "action_id": "aff_003",
      "type": "related",
      "name": "Similar Funding Rounds",
      "description": "Find similar funding events in fintech",
      "endpoint": "/api/v1/search",
      "method": "POST",
      "parameters": {
        "similar_to": "019abc12-3def-7890-abcd-ef1234567890",
        "filters": {"topics": ["fintech"]}
      }
    }
  ],
  
  "license": {
    "license_id": "lic_tc_commercial_v2",
    "type": "commercial",
    "name": "TechCrunch Commercial License v2",
    "permissions": {
      "agent_reasoning": true,
      "output_generation": true,
      "embedding_storage": true,
      "fine_tuning": false,
      "redistribution": false,
      "human_display": false
    },
    "requirements": {
      "attribution": true,
      "attribution_format": "Source: TechCrunch via Orcha",
      "usage_reporting": true
    },
    "restrictions": {
      "competing_products": ["bloomberg.com", "reuters.com"],
      "regions_allowed": ["US", "EU", "UK", "CA", "AU", "NZ"],
      "purpose_excluded": ["training_competing_models"]
    },
    "pricing": {
      "model": "per_event",
      "base_price_cents": 10
    },
    "terms_url": "https://orcha.io/licenses/lic_tc_commercial_v2",
    "terms_hash": "sha256:def456..."
  },
  
  "provenance": {
    "original_url": "https://techcrunch.com/2025/01/21/stripe-series-i",
    "original_published": "2025-01-21T09:15:00Z",
    "captured_at": "2025-01-21T09:20:00Z",
    "processed_at": "2025-01-21T09:25:00Z",
    "processing_model": "claude-3-5-sonnet-20241022",
    "extraction_confidence": 0.94
  },
  
  "relations": {
    "replaces": null,
    "related_events": ["019abc10-1111-7890-abcd-ef1234567890"],
    "thread_id": null,
    "parent_event": null
  },
  
  "extensions": {}
}
```

### 4.4 Field Definitions

#### 4.4.1 Root Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `orcha_version` | string | REQUIRED | Protocol version. MUST be "1.0" for this specification. |
| `event_id` | string | REQUIRED | Globally unique event identifier. MUST be UUID v7 (time-ordered). |
| `feed_id` | string | REQUIRED | Identifier of the feed containing this event. |
| `published_at` | string | REQUIRED | ISO 8601 timestamp when event was published to Orcha. |
| `source` | object | RECOMMENDED | Publisher information and trust signals. |
| `content` | object | REQUIRED | The event content (title, body, summary). |
| `semantic` | object | RECOMMENDED | Semantic metadata and extracted information. |
| `affordances` | array | OPTIONAL | Available actions an agent can take. |
| `license` | object | REQUIRED | Licensing terms for this event. |
| `provenance` | object | RECOMMENDED | Origin and processing history. |
| `relations` | object | OPTIONAL | Links to related events. |
| `extensions` | object | OPTIONAL | Domain-specific extensions. |

#### 4.4.2 Source Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `publisher_id` | string | REQUIRED | Unique publisher identifier. |
| `publisher_name` | string | REQUIRED | Human-readable publisher name. |
| `publisher_url` | string | OPTIONAL | Publisher's website URL. |
| `verified` | boolean | REQUIRED | Whether publisher identity has been verified. |
| `trust_score` | number | OPTIONAL | Publisher reliability score (0.0 to 1.0). |

#### 4.4.3 Content Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | REQUIRED | Content type: "text", "structured", "binary". |
| `title` | string | REQUIRED | Event title or headline. |
| `summary` | string | REQUIRED | Concise summary optimized for quick agent scanning. |
| `summary_tokens` | integer | REQUIRED | Token count of summary (approximate). |
| `body` | string | OPTIONAL | Full content body. |
| `body_tokens` | integer | CONDITIONAL | Token count of body. REQUIRED if body is present. |
| `language` | string | REQUIRED | ISO 639-1 language code. |
| `content_hash` | string | REQUIRED | SHA-256 hash of content for integrity verification. |

#### 4.4.4 Semantic Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event_type` | string | REQUIRED | Standardized event type (see Section 5.2). |
| `entities` | array | REQUIRED | Extracted named entities (see Section 5.3). |
| `topics` | array | REQUIRED | Topic classifications. |
| `metrics` | array | OPTIONAL | Quantitative data extracted from content. |
| `sentiment` | number | OPTIONAL | Sentiment score (-1.0 to 1.0). |
| `importance` | number | RECOMMENDED | Importance/significance score (0.0 to 1.0). |
| `temporal` | object | OPTIONAL | Time-related metadata. |
| `geography` | object | OPTIONAL | Location-related metadata. |

#### 4.4.5 License Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `license_id` | string | REQUIRED | Unique license identifier. |
| `type` | string | REQUIRED | License type (see Section 6.2). |
| `name` | string | REQUIRED | Human-readable license name. |
| `permissions` | object | REQUIRED | Granted permissions (see Section 6.3). |
| `requirements` | object | REQUIRED | Usage requirements (see Section 6.4). |
| `restrictions` | object | OPTIONAL | Usage restrictions (see Section 6.5). |
| `pricing` | object | OPTIONAL | Pricing information. |
| `terms_url` | string | REQUIRED | URL to full license terms. |
| `terms_hash` | string | REQUIRED | Hash of license terms for verification. |

---

## 5. Semantic Layer

### 5.1 Overview

The semantic layer provides structured metadata that enables agents to understand, classify, and act on events without parsing unstructured text. Consistent semantic typing enables cross-feed queries and agent reasoning.

### 5.2 Event Types

Orchadefines a core vocabulary of event types. Publishers MUST use these types when applicable. Custom types MAY be used with the `x-` prefix.

#### 5.2.1 Business Events

| Type | Description |
|------|-------------|
| `funding_round` | Investment or funding announcement |
| `acquisition` | Company acquisition or merger |
| `ipo` | Initial public offering |
| `bankruptcy` | Bankruptcy filing or financial distress |
| `partnership` | Business partnership announcement |
| `executive_change` | Leadership appointment or departure |
| `earnings` | Quarterly/annual earnings report |
| `layoff` | Workforce reduction announcement |
| `expansion` | Geographic or market expansion |
| `product_launch` | New product or service announcement |

#### 5.2.2 Technology Events

| Type | Description |
|------|-------------|
| `release` | Software release or version update |
| `vulnerability` | Security vulnerability disclosure |
| `outage` | Service outage or incident |
| `deprecation` | Feature or API deprecation notice |
| `open_source` | Open source project announcement |

#### 5.2.3 Research Events

| Type | Description |
|------|-------------|
| `paper` | Academic paper publication |
| `patent` | Patent filing or grant |
| `clinical_trial` | Clinical trial announcement or results |
| `discovery` | Scientific discovery or breakthrough |

#### 5.2.4 Regulatory Events

| Type | Description |
|------|-------------|
| `filing` | Regulatory filing (SEC, FDA, etc.) |
| `ruling` | Regulatory decision or ruling |
| `legislation` | New law or regulation |
| `investigation` | Regulatory investigation announcement |

#### 5.2.5 Market Events

| Type | Description |
|------|-------------|
| `price_movement` | Significant price change |
| `trend` | Market trend or pattern emergence |
| `forecast` | Market forecast or prediction |

### 5.3 Entity Schema

Entities represent real-world objects mentioned in events.

```json
{
  "name": "string (required)",
  "type": "string (required)",
  "role": "string (optional)",
  "identifiers": {
    "orcha": "string (optional)",
    "crunchbase": "string (optional)",
    "linkedin": "string (optional)",
    "wikipedia": "string (optional)",
    "ticker": "string (optional)",
    "lei": "string (optional)",
    "custom": "object (optional)"
  },
  "attributes": "object (optional)",
  "confidence": "number (optional, 0.0-1.0)"
}
```

#### 5.3.1 Entity Types

| Type | Description |
|------|-------------|
| `company` | Business organization |
| `person` | Individual human |
| `investor` | Investment entity (VC, PE, angel) |
| `product` | Product or service |
| `location` | Geographic location |
| `organization` | Non-business organization |
| `technology` | Technology, framework, or standard |
| `regulation` | Law, regulation, or policy |

#### 5.3.2 Entity Roles

Roles describe an entity's function within the event context.

| Role | Description |
|------|-------------|
| `subject` | Primary entity the event is about |
| `actor` | Entity performing an action |
| `target` | Entity being acted upon |
| `lead_investor` | Lead investor in funding round |
| `co_investor` | Co-investor in funding round |
| `acquirer` | Company making acquisition |
| `acquiree` | Company being acquired |
| `author` | Content author |
| `source` | Information source |

### 5.4 Metrics Schema

Metrics capture quantitative information extracted from events.

```json
{
  "name": "string (required)",
  "value": "number | string (required)",
  "unit": "string | null (required)",
  "confidence": "number (optional, 0.0-1.0)",
  "context": "string (optional)"
}
```

#### 5.4.1 Standard Metric Names

| Name | Description | Typical Unit |
|------|-------------|--------------|
| `funding_amount` | Investment amount | USD, EUR |
| `valuation` | Company valuation | USD, EUR |
| `revenue` | Revenue figure | USD, EUR |
| `headcount` | Employee count | null |
| `growth_rate` | Growth percentage | percent |
| `market_cap` | Market capitalization | USD |
| `price` | Asset price | USD, BTC |
| `percentage_change` | Change percentage | percent |

### 5.5 Temporal Metadata

```json
{
  "event_time": "ISO 8601 timestamp when the event occurred",
  "relevance_decay": "none | slow | medium | fast",
  "time_sensitivity": "realtime | minutes | hours | days | weeks | none"
}
```

| Decay | Description |
|-------|-------------|
| `none` | Evergreen content, no decay |
| `slow` | Relevant for weeks/months |
| `medium` | Relevant for days/weeks |
| `fast` | Relevant for hours/days |

### 5.6 Geographic Metadata

```json
{
  "primary": {
    "country": "ISO 3166-1 alpha-2",
    "region": "string (optional)",
    "city": "string (optional)",
    "coordinates": {"lat": number, "lon": number} (optional)
  },
  "scope": "local | regional | national | international | global"
}
```

---

## 6. Licensing Framework

### 6.1 Overview

The licensing framework enables content owners to specify how AI agents may use their content. Every event MUST include licensing information. Consumers MUST agree to license terms before accessing events and MUST comply with all applicable restrictions.

### 6.2 License Types

Orchadefines standard license types. Publishers MAY create custom licenses but SHOULD use standard types when applicable.

#### 6.2.1 Open License

For freely available content with minimal restrictions.

```json
{
  "type": "open",
  "permissions": {
    "agent_reasoning": true,
    "output_generation": true,
    "embedding_storage": true,
    "fine_tuning": true,
    "redistribution": true,
    "human_display": true
  },
  "requirements": {
    "attribution": true
  }
}
```

#### 6.2.2 Research License

For academic and non-commercial use.

```json
{
  "type": "research",
  "permissions": {
    "agent_reasoning": true,
    "output_generation": true,
    "embedding_storage": true,
    "fine_tuning": true,
    "redistribution": false,
    "human_display": true
  },
  "requirements": {
    "attribution": true,
    "non_commercial": true,
    "academic_affiliation": true
  }
}
```

#### 6.2.3 Commercial License

For business use with reasoning and output rights.

```json
{
  "type": "commercial",
  "permissions": {
    "agent_reasoning": true,
    "output_generation": true,
    "embedding_storage": true,
    "fine_tuning": false,
    "redistribution": false,
    "human_display": false
  },
  "requirements": {
    "attribution": true,
    "usage_reporting": true,
    "agreement_signed": true
  }
}
```

#### 6.2.4 Training License

For model fine-tuning and training data use.

```json
{
  "type": "training",
  "permissions": {
    "agent_reasoning": true,
    "output_generation": true,
    "embedding_storage": true,
    "fine_tuning": true,
    "model_training": true,
    "redistribution": false,
    "human_display": true
  },
  "requirements": {
    "attribution": true,
    "model_card_disclosure": true,
    "usage_reporting": true
  }
}
```

#### 6.2.5 Enterprise License

For unlimited enterprise use with custom terms.

```json
{
  "type": "enterprise",
  "permissions": {
    "agent_reasoning": true,
    "output_generation": true,
    "embedding_storage": true,
    "fine_tuning": true,
    "model_training": true,
    "redistribution": "sublicense",
    "human_display": true,
    "white_label": true
  },
  "requirements": {
    "custom_agreement": true
  }
}
```

### 6.3 Permissions

| Permission | Description |
|------------|-------------|
| `agent_reasoning` | Use content as input for agent reasoning/inference |
| `output_generation` | Include derived content in agent outputs |
| `embedding_storage` | Store vector embeddings of content |
| `fine_tuning` | Use content to fine-tune models |
| `model_training` | Use content in model pre-training |
| `redistribution` | Redistribute content to third parties |
| `human_display` | Display content directly to human users |
| `white_label` | Remove attribution in commercial products |

### 6.4 Requirements

| Requirement | Description |
|-------------|-------------|
| `attribution` | Include specified attribution in outputs |
| `attribution_format` | Specific attribution text format |
| `usage_reporting` | Report usage statistics to publisher |
| `non_commercial` | Use only for non-commercial purposes |
| `academic_affiliation` | Require academic institution affiliation |
| `agreement_signed` | Require explicit license agreement |
| `model_card_disclosure` | Disclose in model documentation |
| `audit_rights` | Grant publisher audit rights |

### 6.5 Restrictions

| Restriction | Description |
|-------------|-------------|
| `competing_products` | List of prohibited competitor domains |
| `regions_allowed` | Geographic regions where use is permitted |
| `regions_blocked` | Geographic regions where use is prohibited |
| `purpose_excluded` | Prohibited use cases |
| `expiration` | License expiration date |
| `max_events_per_period` | Usage quota |

### 6.6 Pricing Models

```json
{
  "model": "free | per_event | per_token | subscription | custom",
  "base_price_cents": 10,
  "currency": "USD",
  "volume_tiers": [
    {"min": 0, "max": 10000, "price_cents": 10},
    {"min": 10001, "max": 100000, "price_cents": 5},
    {"min": 100001, "max": null, "price_cents": 1}
  ]
}
```

### 6.7 License Agreement Flow

```
1. Consumer discovers feed
   GET /feeds/{feed_id}
   Response includes: license summary, agreement_required: true

2. Consumer retrieves full license terms
   GET /licenses/{license_id}/terms
   Response: Full legal text, version, hash

3. Consumer signs agreement
   POST /licenses/{license_id}/agree
   Body: {
     "organization_id": "...",
     "authorized_signer": "...",
     "terms_hash": "sha256:...",
     "agreed_at": "2025-01-21T10:00:00Z"
   }

4. Consumer receives confirmation
   Response: {
     "agreement_id": "...",
     "status": "active",
     "permissions": {...}
   }

5. Consumer can now access events
   GET /feeds/{feed_id}/events
   Header: X-Orcha-Agreement: {agreement_id}
```

---

## 7. Transport Mechanisms

### 7.1 Overview

Orchasupports multiple transport mechanisms to accommodate different consumer requirements. Implementations MUST support HTTP REST. Implementations SHOULD support at least one real-time mechanism (WebSocket or SSE).

### 7.2 HTTP REST API

#### 7.2.1 Base URL

```
https://{server}/api/v1
```

#### 7.2.2 Authentication

All requests MUST include authentication via API key:

```
Authorization: Bearer {api_key}
```

Or via header:

```
X-Orcha-API-Key: {api_key}
```

#### 7.2.3 Common Headers

Request headers:

| Header | Description |
|--------|-------------|
| `Authorization` | API key authentication |
| `X-Orcha-Agreement` | License agreement ID |
| `Accept` | Response format (application/json) |
| `X-Request-ID` | Client-generated request ID for tracing |

Response headers:

| Header | Description |
|--------|-------------|
| `X-Orcha-Request-ID` | Server request ID |
| `X-Orcha-License` | Applicable license ID |
| `X-Orcha-Cost-Cents` | Cost of this request |
| `X-Orcha-Rate-Limit-Remaining` | Remaining rate limit |
| `X-Orcha-Rate-Limit-Reset` | Rate limit reset timestamp |

#### 7.2.4 Endpoints

**List Feeds**

```
GET /feeds
Query Parameters:
  - category: string (filter by category)
  - publisher: string (filter by publisher)
  - license_type: string (filter by license type)
  - limit: integer (default 20, max 100)
  - offset: integer (pagination offset)
```

**Get Feed**

```
GET /feeds/{feed_id}
```

**List Events**

```
GET /feeds/{feed_id}/events
Query Parameters:
  - since: ISO 8601 timestamp (events after this time)
  - until: ISO 8601 timestamp (events before this time)
  - limit: integer (default 20, max 100)
  - cursor: string (pagination cursor)
  - event_type: string (filter by event type)
  - entity: string (filter by entity ID)
  - min_importance: number (minimum importance score)
```

**Get Event**

```
GET /events/{event_id}
```

**Search Events**

```
POST /search
Body: {
  "query": "string (natural language query)",
  "filters": {
    "feeds": ["feed_id_1", "feed_id_2"],
    "event_types": ["funding_round", "acquisition"],
    "entities": ["ent_stripe"],
    "date_range": {"from": "...", "to": "..."},
    "min_importance": 0.5,
    "topics": ["fintech"]
  },
  "limit": 50,
  "include_embeddings": false
}
```

**Create Subscription**

```
POST /subscriptions
Body: {
  "feed_id": "...",
  "webhook_url": "https://...",
  "filters": {...},
  "secret": "webhook signing secret"
}
```

#### 7.2.5 Response Format

All responses use JSON with consistent structure:

```json
{
  "data": { ... },
  "meta": {
    "request_id": "...",
    "timestamp": "...",
    "cost_cents": 10
  },
  "pagination": {
    "cursor": "...",
    "has_more": true
  }
}
```

Error responses:

```json
{
  "error": {
    "code": "license_required",
    "message": "You must agree to the license before accessing this feed",
    "details": {
      "license_id": "...",
      "agreement_url": "/licenses/.../agree"
    }
  },
  "meta": {
    "request_id": "..."
  }
}
```

#### 7.2.6 Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `invalid_request` | 400 | Malformed request |
| `unauthorized` | 401 | Invalid or missing API key |
| `license_required` | 403 | License agreement required |
| `license_violation` | 403 | Request violates license terms |
| `not_found` | 404 | Resource not found |
| `rate_limited` | 429 | Rate limit exceeded |
| `internal_error` | 500 | Server error |

### 7.3 WebSocket Streaming

#### 7.3.1 Connection

```
wss://{server}/api/v1/stream
```

#### 7.3.2 Protocol

Connection message:

```json
{
  "type": "connect",
  "api_key": "...",
  "subscriptions": [
    {"feed_id": "...", "filters": {...}}
  ]
}
```

Event message:

```json
{
  "type": "event",
  "feed_id": "...",
  "event": { ... }
}
```

Heartbeat (every 30 seconds):

```json
{
  "type": "ping"
}
```

Client must respond:

```json
{
  "type": "pong"
}
```

### 7.4 Server-Sent Events (SSE)

```
GET /feeds/{feed_id}/sse
Accept: text/event-stream
```

Event format:

```
event: orcha_event
id: {event_id}
data: {JSON event object}

event: heartbeat
data: {"timestamp": "..."}
```

### 7.5 Webhooks

#### 7.5.1 Delivery

Events are delivered via HTTP POST to the registered webhook URL.

```
POST {webhook_url}
Content-Type: application/json
X-Orcha-Signature: sha256={signature}
X-Orcha-Event-ID: {event_id}
X-Orcha-Feed-ID: {feed_id}
X-Orcha-Timestamp: {timestamp}

{event JSON}
```

#### 7.5.2 Signature Verification

Signature is HMAC-SHA256 of the request body using the webhook secret:

```
signature = HMAC-SHA256(webhook_secret, request_body)
```

Consumers MUST verify the signature before processing.

#### 7.5.3 Retry Policy

Failed deliveries (non-2xx response) are retried with exponential backoff:

- Attempt 1: Immediate
- Attempt 2: 1 minute
- Attempt 3: 5 minutes
- Attempt 4: 30 minutes
- Attempt 5: 2 hours
- Attempt 6: 8 hours (final)

---

## 8. Discovery and Subscription

### 8.1 Feed Discovery

Orcharegistries provide feed discovery via search and browsing.

#### 8.1.1 Registry API

**Search Feeds by Intent**

```
POST /registry/search
Body: {
  "query": "fintech funding announcements in the US",
  "filters": {
    "license_types": ["commercial", "open"],
    "max_price_cents": 50
  }
}
```

**Browse Categories**

```
GET /registry/categories
GET /registry/categories/{category}/feeds
```

**Get Feed Metadata**

```
GET /registry/feeds/{feed_id}
Response: {
  "feed_id": "...",
  "name": "...",
  "description": "...",
  "publisher": {...},
  "categories": [...],
  "event_types": [...],
  "sample_event": {...},
  "statistics": {
    "events_per_day": 50,
    "avg_importance": 0.7,
    "subscriber_count": 1500
  },
  "license_summary": {...},
  "quality_score": 0.92
}
```

### 8.2 Subscription Management

**Create Subscription**

```
POST /subscriptions
Body: {
  "feed_id": "...",
  "delivery": {
    "method": "webhook | polling | websocket",
    "webhook_url": "..." (if webhook),
    "webhook_secret": "..."
  },
  "filters": {
    "event_types": ["funding_round"],
    "min_importance": 0.7,
    "entities": ["ent_stripe"]
  }
}
```

**List Subscriptions**

```
GET /subscriptions
```

**Update Subscription**

```
PATCH /subscriptions/{subscription_id}
```

**Delete Subscription**

```
DELETE /subscriptions/{subscription_id}
```

### 8.3 Feed Quality Signals

Registries SHOULD provide quality signals:

| Signal | Description |
|--------|-------------|
| `trust_score` | Publisher verification and reliability (0-1) |
| `freshness` | How current the feed is |
| `completeness` | Semantic metadata completeness (0-1) |
| `consistency` | Schema consistency over time (0-1) |
| `subscriber_count` | Number of active subscribers |
| `citation_count` | Times events are cited/referenced |

---

## 9. Security Considerations

### 9.1 Authentication

- API keys MUST be transmitted only over HTTPS
- API keys SHOULD be rotatable without service interruption
- Implementations SHOULD support key scoping (read-only, specific feeds)

### 9.2 Authorization

- License agreements MUST be verified on every request
- Geographic restrictions MUST be enforced via IP geolocation
- Competitor restrictions SHOULD be enforced via organization verification

### 9.3 Data Integrity

- Events MUST include content hash for integrity verification
- License terms MUST include terms hash
- Webhooks MUST be signed with HMAC-SHA256

### 9.4 Rate Limiting

- Implementations MUST enforce rate limits
- Rate limits SHOULD be communicated via response headers
- Implementations SHOULD use token bucket or sliding window algorithms

### 9.5 Privacy

- Usage tracking MUST be disclosed in license terms
- Personal data in events MUST comply with applicable privacy laws
- Implementations SHOULD support data retention limits

---

## 10. Implementation Requirements

### 10.1 Publisher Requirements

Publishers implementing OrchaMUST:

1. Generate valid UUID v7 event IDs
2. Include all required fields per Section 4
3. Provide accurate token counts (±10%)
4. Specify license terms for all events
5. Maintain event immutability after publication

Publishers implementing OrchaSHOULD:

1. Provide semantic metadata (entities, topics, metrics)
2. Include affordances for follow-up actions
3. Support at least one real-time transport
4. Provide sample events for feed discovery

### 10.2 Consumer Requirements

Consumers implementing OrchaMUST:

1. Verify event content hashes
2. Agree to licenses before consuming events
3. Comply with all license requirements
4. Include required attribution in outputs
5. Respect rate limits

Consumers implementing OrchaSHOULD:

1. Cache events appropriately
2. Verify webhook signatures
3. Implement exponential backoff for failures
4. Track and report usage as required

### 10.3 Registry Requirements

Registries implementing OrchaMUST:

1. Verify publisher identity
2. Validate event schema conformance
3. Provide feed search and discovery
4. Track license agreements

---

## 11. Extension Mechanisms

### 11.1 Custom Event Types

Custom event types MUST use the `x-` prefix:

```json
{
  "semantic": {
    "event_type": "x-crypto-whale-alert"
  }
}
```

### 11.2 Custom Entity Types

Custom entity types MUST use the `x-` prefix:

```json
{
  "type": "x-smart-contract"
}
```

### 11.3 Extensions Object

Domain-specific extensions go in the `extensions` object:

```json
{
  "extensions": {
    "crypto": {
      "chain": "ethereum",
      "contract_address": "0x...",
      "transaction_hash": "0x..."
    }
  }
}
```

### 11.4 Extension Namespaces

Extensions SHOULD use namespaced keys:

| Namespace | Domain |
|-----------|--------|
| `crypto` | Cryptocurrency and blockchain |
| `finance` | Financial markets |
| `health` | Healthcare and medicine |
| `legal` | Legal and regulatory |
| `science` | Scientific research |

---

## 12. IANA Considerations

### 12.1 Media Type

This specification defines the media type:

```
application/orcha+json
```

### 12.2 Link Relations

This specification defines link relations:

- `orcha:feed` - Link to Orchafeed
- `orcha:events` - Link to feed events
- `orcha:license` - Link to license terms
- `orcha:subscribe` - Link to subscription endpoint

---

## 13. References

### 13.1 Normative References

- RFC 2119: Key words for use in RFCs
- RFC 8259: JSON Data Interchange Format
- RFC 3339: Date and Time on the Internet: Timestamps
- RFC 4122: UUID URN Namespace
- ISO 8601: Date and time format
- ISO 639-1: Language codes
- ISO 3166-1: Country codes

### 13.2 Informative References

- RSS 2.0 Specification
- Atom Syndication Format (RFC 4287)
- JSON-LD 1.1
- Schema.org
- Creative Commons Licenses
- OpenAPI Specification 3.1

---

## 14. Appendices

### Appendix A: Complete Event Example

```json
{
  "orcha_version": "1.0",
  "event_id": "019abc12-3def-7890-abcd-ef1234567890",
  "feed_id": "fintech-funding-rounds",
  "published_at": "2025-01-21T10:30:00Z",
  "source": {
    "publisher_id": "pub_techcrunch",
    "publisher_name": "TechCrunch",
    "publisher_url": "https://techcrunch.com",
    "verified": true,
    "trust_score": 0.95
  },
  "content": {
    "type": "text",
    "title": "Stripe raises $6.5B Series I at $50B valuation",
    "summary": "Payments giant Stripe closed $6.5B Series I funding round led by Sequoia, valuing the company at $50B, with plans to expand into crypto payments.",
    "summary_tokens": 32,
    "body": "San Francisco-based payments company Stripe has raised $6.5 billion in a Series I funding round, valuing the company at $50 billion. The round was led by Sequoia Capital, with participation from Andreessen Horowitz, General Catalyst, and Tiger Global. The company plans to use the funds to expand its cryptocurrency payment capabilities and accelerate international growth. CEO Patrick Collison stated that the funding will help Stripe 'build the economic infrastructure for the internet's next chapter.' This marks one of the largest private funding rounds in fintech history.",
    "body_tokens": 89,
    "language": "en",
    "content_hash": "sha256:a1b2c3d4e5f6789012345678901234567890abcdef"
  },
  "semantic": {
    "event_type": "funding_round",
    "entities": [
      {
        "name": "Stripe",
        "type": "company",
        "role": "subject",
        "identifiers": {
          "orcha": "ent_stripe_inc",
          "crunchbase": "stripe",
          "linkedin": "company/stripe"
        },
        "attributes": {
          "industry": "fintech",
          "founded": "2010",
          "headquarters": "San Francisco, CA"
        },
        "confidence": 0.99
      },
      {
        "name": "Sequoia Capital",
        "type": "investor",
        "role": "lead_investor",
        "identifiers": {
          "orcha": "ent_sequoia",
          "crunchbase": "sequoia-capital"
        },
        "confidence": 0.98
      },
      {
        "name": "Patrick Collison",
        "type": "person",
        "role": "source",
        "identifiers": {
          "orcha": "ent_patrick_collison",
          "linkedin": "in/patrickcollison"
        },
        "attributes": {
          "title": "CEO",
          "company": "Stripe"
        },
        "confidence": 0.97
      }
    ],
    "topics": ["fintech", "payments", "venture-capital", "crypto", "startups"],
    "metrics": [
      {"name": "funding_amount", "value": 6500000000, "unit": "USD", "confidence": 0.99},
      {"name": "valuation", "value": 50000000000, "unit": "USD", "confidence": 0.99},
      {"name": "funding_round", "value": "Series I", "unit": null, "confidence": 1.0}
    ],
    "sentiment": 0.75,
    "importance": 0.95,
    "temporal": {
      "event_time": "2025-01-21T09:00:00Z",
      "relevance_decay": "slow",
      "time_sensitivity": "hours"
    },
    "geography": {
      "primary": {"country": "US", "region": "California", "city": "San Francisco"},
      "scope": "global"
    }
  },
  "affordances": [
    {
      "action_id": "aff_001",
      "type": "lookup",
      "name": "Get Stripe Profile",
      "description": "Retrieve full company profile including funding history",
      "endpoint": "/api/v1/entities/ent_stripe_inc",
      "method": "GET",
      "cost_cents": 5,
      "response_tokens_estimate": 2500
    },
    {
      "action_id": "aff_002",
      "type": "subscribe",
      "name": "Follow Stripe",
      "description": "Get notified of all future Stripe events",
      "endpoint": "/api/v1/subscriptions",
      "method": "POST",
      "parameters": {"entity_id": "ent_stripe_inc"}
    },
    {
      "action_id": "aff_003",
      "type": "related",
      "name": "Recent Mega-Rounds",
      "description": "Other $1B+ funding rounds this quarter",
      "endpoint": "/api/v1/search",
      "method": "POST",
      "parameters": {
        "filters": {
          "event_types": ["funding_round"],
          "metrics": [{"name": "funding_amount", "min": 1000000000}],
          "date_range": {"from": "2025-01-01"}
        }
      }
    }
  ],
  "license": {
    "license_id": "lic_tc_commercial_v2",
    "type": "commercial",
    "name": "TechCrunch Commercial License v2",
    "permissions": {
      "agent_reasoning": true,
      "output_generation": true,
      "embedding_storage": true,
      "fine_tuning": false,
      "redistribution": false,
      "human_display": false
    },
    "requirements": {
      "attribution": true,
      "attribution_format": "Source: TechCrunch via Orcha",
      "usage_reporting": true
    },
    "restrictions": {
      "competing_products": ["bloomberg.com", "reuters.com"],
      "regions_allowed": ["US", "EU", "UK", "CA", "AU", "NZ", "JP", "SG"],
      "purpose_excluded": ["training_competing_models"]
    },
    "pricing": {
      "model": "per_event",
      "base_price_cents": 10,
      "currency": "USD"
    },
    "terms_url": "https://orcha.io/licenses/lic_tc_commercial_v2",
    "terms_hash": "sha256:def456789012345678901234567890abcdef123456"
  },
  "provenance": {
    "original_url": "https://techcrunch.com/2025/01/21/stripe-series-i-funding",
    "original_published": "2025-01-21T09:15:00Z",
    "captured_at": "2025-01-21T09:20:00Z",
    "processed_at": "2025-01-21T09:25:00Z",
    "processing_model": "claude-3-5-sonnet-20241022",
    "extraction_confidence": 0.96
  },
  "relations": {
    "replaces": null,
    "related_events": [
      "019abc10-1111-7890-abcd-ef1234567890",
      "019abc11-2222-7890-abcd-ef1234567890"
    ],
    "thread_id": null,
    "parent_event": null
  },
  "extensions": {}
}
```

### Appendix B: JSON Schema

The complete JSON Schema for Orchaevents is available at:

```
https://orcha.io/schema/event/v1.0.json
```

### Appendix C: SDK Examples

**Go**

```go
import "github.com/orcha/orcha-go"

client := orcha.NewClient("your-api-key")

// Subscribe to a feed
events, err := client.GetEvents(ctx, "fintech-funding-rounds", &orcha.GetEventsOptions{
    Since:         time.Now().Add(-24 * time.Hour),
    MinImportance: 0.7,
    Limit:         50,
})

// Stream events
stream, err := client.StreamEvents(ctx, "fintech-funding-rounds")
for event := range stream {
    fmt.Printf("New event: %s\n", event.Content.Title)
}
```

**Python**

```python
from orcha import OrchaClient

client = OrchaClient("your-api-key")

# Get recent events
events = client.get_events(
    feed_id="fintech-funding-rounds",
    since=datetime.now() - timedelta(days=1),
    min_importance=0.7,
    limit=50
)

# Search across feeds
results = client.search(
    query="AI startups raising Series A",
    filters={
        "event_types": ["funding_round"],
        "topics": ["artificial-intelligence"]
    }
)
```

**TypeScript**

```typescript
import { OrchaClient } from '@orcha/sdk';

const client = new OrchaClient('your-api-key');

// Get events
const events = await client.getEvents('fintech-funding-rounds', {
  since: new Date(Date.now() - 86400000),
  minImportance: 0.7,
  limit: 50,
});

// Webhook handler
app.post('/webhook', (req, res) => {
  if (!client.verifyWebhook(req)) {
    return res.status(401).send('Invalid signature');
  }
  const event = req.body;
  console.log(`New event: ${event.content.title}`);
  res.status(200).send('OK');
});
```

### Appendix D: Comparison with Existing Standards

| Feature | RSS 2.0 | Atom | JSON Feed | Orcha|
|---------|---------|------|-----------|-----------|
| Format | XML | XML | JSON | JSON |
| Semantic metadata | ❌ | ❌ | ❌ | ✅ |
| Entity extraction | ❌ | ❌ | ❌ | ✅ |
| Token counts | ❌ | ❌ | ❌ | ✅ |
| Licensing | ❌ | ❌ | ❌ | ✅ |
| Affordances | ❌ | ❌ | ❌ | ✅ |
| Streaming | ❌ | ❌ | ❌ | ✅ |
| Search | ❌ | ❌ | ❌ | ✅ |
| Agent-optimized | ❌ | ❌ | ❌ | ✅ |

---

## Acknowledgments

[To be added]

---

## Authors' Addresses

Chann44
Email: 44chansw@gmail.com
---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0-draft-01 | 2025-01-21 | Initial draft |

---

*This document is released under CC BY 4.0. You are free to share and adapt this specification with attribution.*