require "spec_helper"

RSpec.describe "ActiveRecord::SchemaDumper" do
  let(:described_class) { ActiveRecord::SchemaDumper }
  let(:schema_file) { spec_root / "fixtures" / "schema.rb" }

  subject { StringIO.new }

  around :each do |example|
    VersionMatcher.new("activerecord").when "< 5.0" do
      connection.execute "DROP TABLE IF EXISTS ar_internal_metadata"
    end

    load_schema db_config, :ruby, schema_file
    described_class.dump(connection, subject)
    subject.rewind

    begin
      example.run
    ensure
      connection.execute "DROP TABLE IF EXISTS test_table"
      connection.execute "DROP TYPE IF EXISTS foo_type"
    end
  end

  it "contains foo_type in the dump file" do
    expect(subject.string).to include %Q{create_enum "foo_type", %w[bar baz]}
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
