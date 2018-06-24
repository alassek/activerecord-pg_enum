require "spec_helper"

RSpec.describe ActiveRecord::PGEnum do
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
end
