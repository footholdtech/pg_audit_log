module PgAuditLog
  class ActiveRecord
    class << self
      @@audit_classname = 'ActiveRecord::Base'

      def audit_classname
        @@audit_classname
      end

      def audit_classname=(classname)
        @@audit_classname = classname
      end

      private

      def connection
        audit_classname.constantize.connection
      end

      def execute(sql)
        connection.execute(sql)
      end
    end
  end
end
