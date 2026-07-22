# pg_audit_log

NOTE: this repo is a fork of https://github.com/dylanz/pg_audit_log. The original Gem was on Github at casecommons/pg_audit_log, but it has since been taken down. This fork has been maintained only to the extent that it has been updated to be compatible for Rails 7.0 - 8.0.

## Development

Setup the test database, if you haven't already:

```console
$ createdb pg_audit_log_test
```

We use the [appraisal](https://github.com/thoughtbot/appraisal) gem to ensure compatibility with multiple Rails versions during upgrades. If you need to ensure support for a new Rails version, add it to the `Appraisals` file.

Install all gems from the `Appraisals` file:

```console
$ bundle exec appraisal install
```

Run specs across all versions in the `Appraisals` file:

```console
$ bundle exec appraisal rake
```

Or run specs for a single version:

```console
$ bundle exec appraisal rails-7-0 rake
```

## Description

PostgreSQL-only database-level audit logging of all databases changes using a completely transparent stored procedure and triggers.
Comes with specs for your project and a rake task to generate the reverse SQL to undo changes logged.

All SQL `INSERT`s, `UPDATE`s, and `DELETE`s will be captured. Record columns that do not change do not generate an audit log entry.

## Installation

- Generate the appropriate Rails files:

        rails generate pg_audit_log:install

- Install the PostgreSQL function and triggers for your project:

        rake pg_audit_log:install

## Usage

The PgAuditLog::Entry ActiveRecord model represents a single entry in the audit log table. Each entry represents a single change to a single field of a record in a table. So if you change 3 columns of a record, that will generate 3 corresponding PgAuditLog::Entry records.

You can see the SQL it injects on every query by running with LOG_AUDIT_SQL

### Migrations

TODO

### schema.rb and development_structure.sql

Since schema.rb cannot represent TRIGGERs or FUNCTIONs you will need to set your environment to generate SQL instead of Ruby for your database schema and structure. In your application environment put the following:

    config.active_record.schema_format = :sql

And you can generate this sql using:

    rake db:structure:dump

## Uninstalling

    rake pg_audit_log:uninstall

## Performance

On a 2.93GHz i7 with PostgreSQL 9.1 the audit log has an overhead of about 0.0035 seconds to each `INSERT`, `UPDATE`, or `DELETE`.

## Requirements

- ActiveRecord
- PostgreSQL
- Rails 3.2, 4.x, <5.3

## LICENSE

Copyright © 2010–2014 Case Commons, LLC. Licensed under the MIT license, available in the “LICENSE” file.

# FCM Annotations

> Added during the Rails 8 upgrade (FCM-8671). Everything above is the upstream README,
> kept as-is; the notes below reflect how we develop and test this fork locally.

## Local test database & specs

### Requirements

- **PostgreSQL** — a running server is required (currently validated against 17.4). Install it via Homebrew (`brew install postgresql@17`) or another tool, and start it before setting up the database.
- **Ruby** — developed against 3.3.11.

### Set up the test database

Rake tasks are provided so you don't have to run raw SQL:

```console
$ bundle install
$ bundle exec rake db:setup      # create pg_audit_log_test + install the audit_log schema
```

Lower-level tasks are also available: `db:create`, `db:migrate`, `db:drop`, `db:reset`. This gem has no versioned migrations — its schema is the `audit_log` table plus the audit functions — so `db:migrate` just installs those, and there is no rollback task. The connection reads the same environment variables that upstream `spec/spec_helper.rb` already uses — `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` (all optional; anything unset falls back to the local socket and your OS user). The database name is `pg_audit_log_test`, hardcoded in `spec_helper.rb`. Because the task and the specs read the same variables, a single `DB_USER=… DB_PASSWORD=…` applies to both. (`createdb pg_audit_log_test` also works — the suite installs the schema itself on each run.)

### Run the specs

```console
$ bundle exec rspec
```

No fixtures or seed data are needed (or shipped): the suite uses [`with_model`](https://github.com/Casecommons/with_model) to define throwaway tables per example and reinstalls the audit schema on each run.
