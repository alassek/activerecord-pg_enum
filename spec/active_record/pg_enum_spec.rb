require "spec_helper"

RSpec.describe ActiveRecord::PGEnum do
  class TestTable < ActiveRecord::Base
    self.table_name = "test_table"
    include ActiveRecord::PGEnum::Helper
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

  describe ActiveRecord::PGEnum::Helper do
    subject { TestTable }

    it { is_expected.to respond_to :pg_enum }

    it "converts arrays of values into hashes for ::enum" do
      expect(TestTable).to receive(:enum).with(foo_type: { bar: "bar", baz: "baz" }).and_call_original

      TestTable.pg_enum foo_type: %i[bar baz]

      expect(TestTable).to respond_to :foo_types
      expect(TestTable.foo_types).to match({ "bar" => "bar", "baz" => "baz" })
    end
  end
end
