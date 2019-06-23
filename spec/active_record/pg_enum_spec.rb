require "spec_helper"

RSpec.describe ActiveRecord::PGEnum do
  let(:schema_file) { spec_root / "fixtures" / "schema.rb" }

  before { load_schema(db_config, :ruby, schema_file) }

  after :each do
    connection.execute "DROP TABLE IF EXISTS test_table"
    connection.execute "DROP TYPE IF EXISTS foo_type"
  end

  class TestTable < ActiveRecord::Base
    self.table_name = "test_table"
  end

  let(:column) { TestTable.columns.detect { |col| col.name == "foo" } }

  it "defines columns as enum type" do
    expect(column.type).to eq :enum
    expect(column.sql_type).to eq "foo_type"
  end

  it "allows defined enum values to be created" do
    expect { TestTable.create!(foo: "bar") }.to_not raise_error
    expect { TestTable.create!(foo: "baz") }.to_not raise_error
  end

  it "does not allow any other values" do
    expect { TestTable.create!(foo: "quux") }.to raise_error(ActiveRecord::StatementInvalid)
  end

  describe "ActiveRecord::PGEnum()" do
    subject { TestTable }

    it "converts arrays of values into hashes for ::enum" do
      expect(TestTable).to receive(:enum).with(foo_type: { bar: "bar", baz: "baz" }).and_call_original

      TestTable.include ActiveRecord.PGEnum(foo_type: %i[bar baz])

      expect(TestTable).to respond_to :foo_types
      expect(TestTable.foo_types).to match({ "bar" => "bar", "baz" => "baz" })
    end
  end
end
