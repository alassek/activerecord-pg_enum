require "spec_helper"

RSpec.describe "ActiveRecord::SchemaDumper", version: "< 7.0" do
  let(:described_class) { ActiveRecord::SchemaDumper }
  let(:schema_file) { spec_root / "fixtures" / "schema.rb" }

  subject { StringIO.new }

  before :each do
    version.when "< 5.0" do
      connection.execute "DROP TABLE IF EXISTS ar_internal_metadata"
      db_tasks.load_schema_for db_config, :ruby, schema_file
    end

    version.when ">= 5.0" do
      db_tasks.load_schema db_config, :ruby, schema_file
    end

    described_class.dump(connection, subject)
    subject.rewind

    connection.execute "DROP TABLE IF EXISTS test_table"
    connection.execute "DROP TYPE IF EXISTS foo_type"
  end

  it "contains foo_type in the dump file" do
    expect(subject.string).to include %Q{create_enum "foo_type", ["bar", "baz", "fizz buzz"]}
  end

  it "dumps the table definition" do
    expect(subject.string).to include %Q{t.enum "foo", null: false, as: "foo_type"}
  end

  it "places create_enum after enable_extension and before create_table" do
    ext, enum, table = 0, 0, 0

    subject.each_line.with_index do |line, i|
      case line
      when /^\s+enable_extension/
        ext = i
      when /^\s+create_enum/
        enum = i
      when /^\s+create_table/
        table = i
      end
    end

    expect(ext).to be < enum
    expect(enum).to be > ext
    expect(table).to be > enum
  end
end
