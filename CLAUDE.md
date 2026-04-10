# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0 API backend project (`admin_api/`) for an enterprise management system with modules for CRM, FM (Contract Management), RMS, IQC, MFG (Manufacturing), WMS, TMS, MAT (Materials), PM (Project Management), and more.

## Tech Stack

- **Framework**: Rails 8.0.2 (API mode)
- **Ruby**: 3.4.3
- **Database**: MySQL 8.4 (production), SQLite3 (development default)
- **Authentication**: JWT + Devise
- **Authorization**: CanCanCan
- **Asset Pipeline**: Propshaft + Importmap
- **Background Jobs**: Solid Queue + Mission Control
- **Deployment**: Kamal (Docker)

## Commands

```bash
# Setup
bundle install
bin/rails db:migrate

# Development
bin/rails server
bin/rails console
bin/rails db:migrate
bin/rails runner "code"

# Generate code
bin/rails generate model ModelName fields...
bin/rails generate api:v1:scaffold_controller ModelName --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test

# Delete
bin/rails destroy model ModelName
bin/rails destroy scaffold ModelName

# Credentials (edit encrypted credentials)
VISUAL="code --wait" bin/rails credentials:edit

# Database
bin/rails db:seed

# Code quality
bin/brakeman --no-pager       # Security scan
bin/rubocop                   # Linting
```

## Architecture

### Directory Structure

```
admin_api/
├── app/
│   ├── controllers/api/v1/    # API controllers (v2 for public APIs)
│   ├── controllers/admin/     # Admin panel controllers
│   ├── models/                # ActiveRecord models
│   │   ├── concerns/          # Reusable model concerns (e.g., DocNumberable)
│   │   └── {module}/          # Namespaced models (crm, fm, mfg, etc.)
│   └── services/              # Business logic services
├── config/
│   ├── routes.rb              # API routes organized by module
│   └── workflow/              # Module-specific route files
├── db/                        # Migrations and seeds
└── docs/                      # Architecture and design docs
```

### Module Namespace Convention

Business modules are organized by domain:
- `crm/` - Customer Relationship Management
- `fm/` - Contract Management (FanWu)
- `rms/` - Retail Management
- `iqc/` - Incoming Quality Control
- `mfg/` - Manufacturing
- `wms/` - Warehouse Management
- `tms/` - Transportation Management
- `mat/` - Materials Management
- `pm/` - Project Management
- `pur/` - Purchasing

### API Controller Pattern

All API controllers inherit from `Api::V1::BaseController` which provides:
- JWT authentication (`set_current_user`)
- IP-based security checks (blacklist/whitelist)
- Time-based access restrictions
- Logging (security, audit, operation logs)
- Standardized response helpers (`req_success`, `req_fail`, `login_other`)

Authentication uses Bearer token in `Authorization` header with JWT.

### Document Number System

Configurable document number generation via `DocNumberable` concern:

```ruby
# In model
class Fm::Contract < ApplicationRecord
  include DocNumberable
  self.doc_number_key = "fm_contracts"
end
```

Rules stored in `doc_number_rules` table with format patterns like `FM-{YYMMDD}-{seq:4}`.

### Workflow System

Configurable workflow engine for contract approval processes:
- `workflow_templates` - Template definitions
- `workflow_nodes` - Node definitions with position
- `workflow_edges` - Flow connections
- `workflow_node_results` - Branch conditions

Use `FmContractWorkflowService` for execution.

### Permission Model

Four permission levels:
1. **All** - Super admin (id=1)
2. **Company** - `company_id` scoped
3. **Department** - `department_id` scoped (supports hierarchy via `ancestry`)
4. **Self** - `user_id` scoped

Managed via `Ability` class with CanCanCan.

### Key Configuration

```ruby
# config/application.rb
config.time_zone = "Beijing"
config.active_record.default_timezone = :local
```

### Database

- MySQL with `utf8mb4` charset
- Foreign key checks disabled for migrations (`SET FOREIGN_KEY_CHECKS = 0`)
- Use `activerecord-import` for bulk inserts
- Will-paginate for pagination

### Utilities

- `chinese_pinyin` - Convert Chinese to pinyin for search
- `carrierwave` - File uploads (S3 compatible)
- `creek` / `caxlsx` - Excel processing
- `jwt` - Token authentication
- `ancestry` - Tree structures (departments, menus)

## Important Files

| File | Description |
|------|-------------|
| `config/routes.rb` | Main routes, draws module-specific routes from `config/workflow/` |
| `app/controllers/api/v1/base_controller.rb` | Base API controller with auth/logging |
| `app/models/application_record.rb` | Base model with callbacks and utilities |
| `app/models/concerns/doc_numberable.rb` | Document number generation |
| `app/services/doc_number_service.rb` | Document number logic |
| `app/models/ability.rb` | CanCanCan abilities |
| `docs/` | Design docs for workflows, document numbers, forms |
