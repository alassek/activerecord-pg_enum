require "spec_helper"

RSpec.describe ActiveRecord::PGEnum do
  let(:schema_file) { spec_root / "fixtures" / "schema.rb" }

  before :each do
    version
      .when("< 5.0")  { db_tasks.load_schema_for db_config, :ruby, schema_file }
      .when(">= 5.0") { db_tasks.load_schema db_config, :ruby, schema_file }
  end

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

  describe "PGEnum()" do
    subject { TestTable }

    it "converts arrays of values into hashes for ::enum" do
      expect(TestTable).to receive(:enum).with(foo_type: { bar: "bar", baz: "baz" }).and_call_original

      TestTable.include PGEnum(foo_type: %i[bar baz])

      expect(TestTable).to respond_to :foo_types
      expect(TestTable.foo_types).to match({ "bar" => "bar", "baz" => "baz" })
    end

    it "passes any additional options to ::enum", version: ">= 5.0" do
      expect(TestTable).to receive(:enum).with(foo_type: { bar: "bar", baz: "baz" }, _prefix: true, _suffix: 'fizz').and_call_original

      TestTable.include PGEnum(foo_type: %i[bar baz], _prefix: true, _suffix: 'fizz')

      expect(TestTable).to respond_to :foo_type_bar_fizz
      expect(TestTable.new).to respond_to :foo_type_bar_fizz?
      expect(TestTable.new).to respond_to :foo_type_baz_fizz!
    end
  end
end
