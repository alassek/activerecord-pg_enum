require "spec_helper"

RSpec.describe ActiveRecord::PGEnum::SchemaStatements do
  subject { ActiveRecord::MigrationContext.new(spec_root / "migrations") }

  context "up" do
    before :each do
      ActiveRecord::SchemaMigration.drop_table
      execute "DROP TYPE IF EXISTS status_type"
    end

    after :each do
      ActiveRecord::SchemaMigration.drop_table
      execute "DROP TYPE IF EXISTS status_type"
    end

    it "creates a new enum" do
      expect(subject.current_version).to eq 0
      expect { subject.up(1) }.to_not raise_error
      expect(subject.current_version).to eq 1
      expect(connection.enum_types).to include("status_type" => %w[active archived])
    end
  end

  context "down" do
    before :each do
      execute "DROP TYPE IF EXISTS status_type"
      execute "CREATE TYPE status_type AS ENUM ('active', 'archived')"
      ActiveRecord::SchemaMigration.tap(&:create_table).find_or_create_by(version: 1)
    end

    it "drops the enum type" do
      expect(subject.current_version).to eq 1
      expect { subject.down(0) }.to_not raise_error
      expect(subject.current_version).to eq 0
      expect(connection.enum_types).to_not include("status_type" => %w[active archived])
    end
  end
end
