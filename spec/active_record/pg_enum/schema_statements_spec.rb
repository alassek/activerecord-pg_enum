require "spec_helper"

RSpec.describe ActiveRecord::PGEnum::SchemaStatements do
  with_migration :AddStatuses, 1, <<-EOF
    def up
      create_enum "status_type", %w[active archived]
    end

    def down
      drop_enum :status_type
    end
  EOF

  subject { migration_context }

  context "create_enum" do
    before :each do
      ActiveRecord::SchemaMigration.drop_table
      execute "DROP TYPE IF EXISTS status_type"
    end

    after :each do
      ActiveRecord::SchemaMigration.drop_table
      execute "DROP TYPE IF EXISTS status_type"
    end

    it "creates a new enum", version: ">= 5.2.0" do
      expect(subject.current_version).to eq 0
      expect { subject.up(1) }.to_not raise_error
      expect(subject.current_version).to eq 1
      expect(connection.enum_types).to include("status_type" => %w[active archived])
    end

    it "creates a new enum", version: "< 5.2.0" do
      legacy_migrator do |subject|
        expect(subject.current_version).to eq 0
        expect { subject.up(migration_path, 1) }.to_not raise_error
        expect(subject.current_version).to eq 1
        expect(connection.enum_types).to include("status_type" => %w[active archived])
      end
    end
  end

  context "drop_enum" do
    before :each do
      execute "DROP TYPE IF EXISTS status_type"
      execute "CREATE TYPE status_type AS ENUM ('active', 'archived')"
      ActiveRecord::SchemaMigration.tap(&:create_table).find_or_create_by(version: "1")
    end

    it "drops the enum type", version: ">= 5.2.0" do
      expect(subject.current_version).to eq 1
      expect { subject.down(0) }.to_not raise_error
      expect(subject.current_version).to eq 0
      expect(connection.enum_types).to_not include("status_type" => %w[active archived])
    end

    it "drops the enum type", version: "< 5.2.0" do
      legacy_migrator do |subject|
        expect(subject.current_version).to eq 1
        expect { subject.down(migration_path, 0) }.to_not raise_error
        expect(subject.current_version).to eq 0
        expect(connection.enum_types).to_not include("status_type" => %w[active archived])
      end
    end
  end
end
