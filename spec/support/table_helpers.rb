require "active_record"

module TableHelpers
  def dump_table_schema(table, connection = ActiveRecord::Base.connection)
    original_ignore_tables = ActiveRecord::SchemaDumper.ignore_tables
    ActiveRecord::SchemaDumper.ignore_tables = connection.data_sources - [table]

    stream = StringIO.new
    ActiveRecord::SchemaDumper.dump(connection, stream)
    stream.string
  ensure
    ActiveRecord::SchemaDumper.ignore_tables = original_ignore_tables
  end

  def connection
    ActiveRecord::Base.connection
  end

  delegate :execute, to: :connection
end
