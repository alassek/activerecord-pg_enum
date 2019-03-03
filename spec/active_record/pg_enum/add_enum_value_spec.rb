require "spec_helper"

RSpec.describe "add_enum_value" do
  around :each do |example|
    execute "CREATE TYPE another_test_type AS ENUM ('foo', 'bar')"
    example.run
    execute "DROP TYPE another_test_type"
  end

  def subject
    connection.enum_types["another_test_type"]
  end

  it { is_expected.to eq %w[foo bar] }

  describe "add a new type with no other options" do
    it "appends the new value to the end" do
      expect { connection.add_enum_value "another_test_type", "baz" }.to_not raise_error
      expect(subject).to eq %w[foo bar baz]
    end
  end

  describe "add a new type with AFTER clause" do
    it "inserts the new value in the correct order" do
      expect { connection.add_enum_value "another_test_type", "quux", after: "foo" }.to_not raise_error
      expect(subject).to eq %w[foo quux bar]
    end
  end

  describe "add a new type with BEFORE clause" do
    it "inserts the new value in the correct order" do
      expect { connection.add_enum_value "another_test_type", "quux", before: "foo" }.to_not raise_error
      expect(subject).to eq %w[quux foo bar]
    end
  end

  describe "add a new type with both BEFORE and AFTER" do
    it "raises an ArgumentError" do
      expect { connection.add_enum_value "another_test_type", "quux", before: "bar", after: "foo" }.to raise_error(ArgumentError)
    end
  end

  describe "migration" do
    let(:path) { spec_root / "migrations" / "add_enum_value_spec" }

    around :each do |example|
      ActiveRecord::SchemaMigration.tap(&:create_table).find_or_create_by(version: 1)
      with_migrator(path) do |migrator|
        example.metadata[:migrator] = migrator
        example.run
      end
      ActiveRecord::SchemaMigration.where(version: 2).delete_all
    end

    def definition
      connection.enum_types["another_test_type"]
    end

    context ">= 5.2.0", version: ">= 5.2.0" do
      it "supports change in the forward direction" do |example|
        subject = example.metadata[:migrator]

        expect { subject.up(2) }.to change(subject, :current_version).from(1).to(2)
        expect(definition).to eq %w[foo bar baz]
      end

      it "raises an IrreversibleMigration if rolled back" do |example|
        execute "ALTER TYPE another_test_type ADD VALUE 'baz'"
        ActiveRecord::SchemaMigration.find_or_create_by(version: 2)

        subject = example.metadata[:migrator]

        # ActiveRecord::Migrator traps IrreversibleMigration and reraises a StandardError
        expect { subject.down(1) }.to raise_error(StandardError)
      end
    end

    context "< 5.2.0", version: "< 5.2.0" do
      let(:migrations) { ActiveRecord::Migrator.migrations(path) }

      it "supports change in the forward direction" do |example|
        migrator = example.metadata[:migrator]
        subject  = migrator.new(:up, migrations, 2)

        expect { subject.run }.to change(subject, :current_version).from(1).to(2)
        expect(definition).to eq %w[foo bar baz]
      end

      it "raises an IrreversibleMigration if rolled back" do |example|
        execute "ALTER TYPE another_test_type ADD VALUE 'baz'"
        ActiveRecord::SchemaMigration.find_or_create_by(version: 2)

        migrator = example.metadata[:migrator]
        subject  = migrator.new(:down, migrations, 1)

        expect { subject.migrate }.to raise_error(StandardError)
      end
    end
  end
end
