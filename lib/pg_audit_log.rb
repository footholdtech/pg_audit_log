module PgAuditLog
  IGNORED_TABLES = [
    'plugin_schema_migrations'.freeze,
    'sessions'.freeze,
    'schema_migrations'.freeze,
  ]
end

# must `require 'logger'` before `active_record` for Rails v7.0 and lower
# can be removed if we drop support for 7.0 because Rails does this now (https://github.com/rails/rails/pull/49372)
require 'logger'
require 'active_record'
require 'pg_audit_log/version'

require 'pg_audit_log/extensions/postgresql_adapter.rb'
require 'pg_audit_log/active_record'
require 'pg_audit_log/entry'
require 'pg_audit_log/function'
require 'pg_audit_log/triggers'
