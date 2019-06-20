require "spec_helper"

RSpec.describe ActiveRecord::PGEnum::TableDefinition do
  let(:path) { spec_root / "migrations" / "table_definition_spec" }

  around :each do |example|
    ActiveRecord::SchemaMigration.drop_table
    execute "DROP TYPE IF EXISTS status_type"
    execute "CREATE TYPE status_type AS ENUM ('active', 'archived')"

    example.run

    ActiveRecord::SchemaMigration.drop_table
    execute "DROP TABLE IF EXISTS quux"
    execute "DROP TYPE IF EXISTS status_type"
  end

  class Quux < ActiveRecord::Base
    self.table_name = "quux"
  end

  it "understands enum as a column type", version: ">= 5.2.0" do
    with_migrator(path) do |subject|
      expect { subject.up(1) }.to_not raise_error

      column = Quux.columns.detect { |col| col.name == "status" }

      expect(column).to_not be_nil
      expect(column.sql_type).to eq "status_type"
    end
  end

  it "understands enum as a column type", version: "< 5.2.0" do
    with_migrator(path) do |subject|
      expect { subject.up(path, 1) }.to_not raise_error

      column = Quux.columns.detect { |col| col.name == "status" }

      expect(column).to_not be_nil
      expect(column.sql_type).to eq "status_type"
    end
  end
end
