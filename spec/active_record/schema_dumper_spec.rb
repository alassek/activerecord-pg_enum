require "spec_helper"

RSpec.describe "ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper", version: "~> 5.2" do
  let(:described_class) { ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper }
  subject { StringIO.new }

  before(:each) { described_class.dump(connection, subject) }
  before(:each) { subject.rewind }

  it "contains foo_type in the dump file" do
    expect(subject.string).to include %Q{create_enum "foo_type", %w[bar baz]}
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
