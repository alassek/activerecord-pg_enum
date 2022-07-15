require "spec_helper"

RSpec.describe ActiveRecord::PGEnum::SchemaStatements do
  with_migration :AddStatuses, 1, <<-EOF
    def up
      create_enum "status_type", ['active', 'archived', 'on hold']
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
      expect(enum_types).to include("status_type" => ['active', 'archived', 'on hold'])
    end

    it "creates a new enum", version: "< 5.2.0" do
      legacy_migrator do |subject|
        expect(subject.current_version).to eq 0
        expect { subject.up(migration_path, 1) }.to_not raise_error
        expect(subject.current_version).to eq 1
        expect(enum_types).to include("status_type" => ['active', 'archived', 'on hold'])
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
      expect(enum_types).to_not include("status_type" => %w[active archived])
    end

    it "drops the enum type", version: "< 5.2.0" do
      legacy_migrator do |subject|
        expect(subject.current_version).to eq 1
        expect { subject.down(migration_path, 0) }.to_not raise_error
        expect(subject.current_version).to eq 0
        expect(enum_types).to_not include("status_type" => %w[active archived])
      end
    end
  end

  context "rename_enum" do
    with_migration :RenameStatusType, 2, <<-EOF
      def change
        rename_enum "status_type", to: "order_status_type"
      end
    EOF

    before :each do
      ActiveRecord::SchemaMigration.drop_table
      execute "DROP TYPE IF EXISTS status_type"
    end

    after :each do
      ActiveRecord::SchemaMigration.drop_table
      execute "DROP TYPE IF EXISTS status_type"
      execute "DROP TYPE IF EXISTS order_status_type"
    end

    let(:statuses) { ["active", "archived", "on hold"] }

    it "renames an existing type", version: ">= 5.2.0" do
      subject.up(1)
      expect { subject.up(2) }.to change { enum_types }.from("status_type" => statuses).to("order_status_type" => statuses)
    end

    it "renames an existing type", version: "< 5.2.0" do
      legacy_migrator do |subject|
        subject.up(migration_path, 1)
        expect { subject.up(migration_path, 2) }.to change { enum_types }.from("status_type" => statuses).to("order_status_type" => statuses)
      end
    end

    it "is reversible", version: ">= 5.2.0" do
      subject.up(2)
      expect { subject.down(1) }.to_not raise_error
      expect(enum_types).to include("status_type")
    end

    it "is reversible", version: "< 5.2.0" do
      legacy_migrator do |subject|
        subject.up(migration_path, 2)
        expect { subject.down(migration_path, 1) }.to_not raise_error
        expect(enum_types).to include("status_type")
      end
    end
  end

  context "rename_enum_value" do
    with_migration :CamelizeStatuses, 2, <<-EOF
      def change
        rename_enum_value "status_type", from: "active", to: "Active"
        rename_enum_value "status_type", from: "archived", to: "Archived"
        rename_enum_value "status_type", from: "on hold", to: "OnHold"
      end
    EOF

    before :each do
      ActiveRecord::SchemaMigration.drop_table
      execute "DROP TYPE IF EXISTS status_type"
    end

    after :each do
      ActiveRecord::SchemaMigration.drop_table
      execute "DROP TYPE IF EXISTS status_type"
    end

    it "changes ENUM labels", version: ">= 5.2.0" do
      subject.up(1)
      expect { subject.up(2) }.to change { enum_types["status_type"] }.from(["active", "archived", "on hold"]).to(["Active", "Archived", "OnHold"])
    end

    it "changes ENUM labels", version: "< 5.2.0" do
      legacy_migrator do |subject|
        subject.up(migration_path, 1)
        expect { subject.up(migration_path, 2) }.to change { enum_types["status_type"] }.from(["active", "archived", "on hold"]).to(["Active", "Archived", "OnHold"])
      end
    end

    it "is reversible", version: ">= 5.2.0" do
      subject.up(2)
      expect { subject.down(1) }.to_not raise_error
      expect(enum_types["status_type"]).to eq ["active", "archived", "on hold"]
    end

    it "is reversible", version: "< 5.2.0" do
      legacy_migrator do |subject|
        subject.up(migration_path, 2)
        expect { subject.down(migration_path, 1) }.to_not raise_error
        expect(enum_types["status_type"]).to eq ["active", "archived", "on hold"]
      end
    end
  end
end
