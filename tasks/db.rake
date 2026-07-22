# frozen_string_literal: true
#
# Minimal, Rails-like database tasks for pg_audit_log's OWN test database.
#
# This gem ships no versioned migration files -- its "schema" is the `audit_log`
# table plus the audit trigger/function, which are installed programmatically.
# So `db:migrate` here simply installs that schema; there are no step-by-step
# migrations and therefore no rollback task. Tear down with `db:drop`.
#
# Connection settings intentionally mirror the upstream spec/spec_helper.rb so a
# single set of env vars works for both `rake db:*` and the specs. spec_helper.rb
# reads these (all optional; anything unset falls back to libpq defaults — the
# local socket + current OS user):
#   DB_HOST, DB_PORT, DB_USER, DB_PASSWORD
# The database name is pg_audit_log_test (hardcoded in spec_helper.rb).
#
# Usage:
#   bundle exec rake db:setup    # create the database + install the schema
#   bundle exec rake db:create   # create the pg_audit_log_test database only
#   bundle exec rake db:migrate  # install the audit_log table + functions only
#   bundle exec rake db:reset    # drop + create + migrate
#   bundle exec rake db:drop     # tear the database down

def pg_audit_log_test_database
  # Hardcoded in spec/spec_helper.rb; kept identical here on purpose.
  "pg_audit_log_test"
end

def pg_audit_log_db_config(database)
  {
    adapter:      "postgresql",
    database:     database,
    host:         ENV.fetch("DB_HOST", nil),
    port:         ENV.fetch("DB_PORT", nil),
    user:         ENV.fetch("DB_USER", nil),
    password:     ENV.fetch("DB_PASSWORD", nil),
    min_messages: "warning"
  }
end

# CREATE DATABASE / DROP DATABASE cannot run from inside the target database, so
# connect to the "postgres" maintenance database for those operations.
def pg_audit_log_on_maintenance_db
  require "pg_audit_log"
  ActiveRecord::Base.establish_connection(pg_audit_log_db_config("postgres"))
  yield ActiveRecord::Base.connection
ensure
  ActiveRecord::Base.connection_pool.disconnect! if ActiveRecord::Base.connected?
end

namespace :db do
  desc "Create the pg_audit_log_test database"
  task :create do
    pg_audit_log_on_maintenance_db do |connection|
      connection.create_database(pg_audit_log_test_database)
      puts "Created database '#{pg_audit_log_test_database}'."
    end
  rescue ActiveRecord::StatementInvalid => e
    raise unless e.cause.is_a?(PG::DuplicateDatabase)

    puts "Database '#{pg_audit_log_test_database}' already exists; skipping."
  end

  desc "Drop the pg_audit_log_test database"
  task :drop do
    pg_audit_log_on_maintenance_db do |connection|
      connection.drop_database(pg_audit_log_test_database)
      puts "Dropped database '#{pg_audit_log_test_database}'."
    end
  end

  desc "Install the audit_log table + functions (no versioned migrations exist)"
  task :migrate do
    require "pg_audit_log"
    ActiveRecord::Base.establish_connection(pg_audit_log_db_config(pg_audit_log_test_database))
    PgAuditLog::Entry.install unless PgAuditLog::Entry.installed?
    PgAuditLog::Function.install
    puts "Installed audit_log schema into '#{pg_audit_log_test_database}'."
  end

  desc "Create the database and install the schema"
  task setup: %i[create migrate]

  desc "Drop, recreate, and reinstall the schema"
  task reset: %i[drop create migrate]
end
