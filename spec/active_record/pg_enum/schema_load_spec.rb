require "spec_helper"

RSpec.describe ActiveRecord::Tasks::DatabaseTasks do
  let(:schema_file) { spec_root / "fixtures" / "schema.rb" }

  def load_schema
    ActiveRecord::Tasks::DatabaseTasks.load_schema db_config, :ruby, schema_file
  end

  it "loads a schema file with create_enum successfully" do
    connection.execute "DROP TABLE IF EXISTS test_table"
    connection.execute "DROP TYPE IF EXISTS foo_type"

    expect(connection.enum_types).to be_empty
    expect(connection.data_sources).to_not include("test_table")

    expect { load_schema }.to_not raise_error

    expect(connection.enum_types).to include({ "foo_type" => %w[bar baz] })
    expect(connection.data_sources).to include("test_table")
  end
end
