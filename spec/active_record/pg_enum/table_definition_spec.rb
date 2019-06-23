require "spec_helper"

RSpec.describe ActiveRecord::PGEnum::TableDefinition do
  with_migration "AddStatusToQuux", 1, <<-EOF
    def change
      create_table :quux do |t|
        t.enum :status, as: "status_type"
      end
    end
  EOF

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

  context "MigrationContext", version: ">= 5.2.0" do
    subject { migration_context }

    it "understands enum as a column type" do
      expect { subject.up(1) }.to_not raise_error

      column = Quux.columns.detect { |col| col.name == "status" }

      expect(column).to_not be_nil
      expect(column.sql_type).to eq "status_type"
    end
  end

  context "Migrator", version: "< 5.2.0" do
    it "understands enum as a column type" do
      legacy_migrator do |subject|
        expect { subject.up(migration_path, 1) }.to_not raise_error

        column = Quux.columns.detect { |col| col.name == "status" }

        expect(column).to_not be_nil
        expect(column.sql_type).to eq "status_type"
      end
    end
  end
end
