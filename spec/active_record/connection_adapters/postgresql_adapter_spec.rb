require "spec_helper"

RSpec.describe "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter", version: [:>=, "5.2.0"] do
  subject { connection }

  it { is_expected.to respond_to :enum_types }

  context "with multiple types defined" do
    before :each do
      execute "CREATE TYPE quux_type AS ENUM ('quux')"
      execute "CREATE TYPE baz_type AS ENUM ('baz')"
      execute "CREATE TYPE bar_type AS ENUM ('bar')"
    end

    after :each do
      execute "DROP TYPE quux_type"
      execute "DROP TYPE baz_type"
      execute "DROP TYPE bar_type"
    end

    it "lists types in alphabetical order" do
      expect(subject.enum_types.keys).to eq %w[bar_type baz_type foo_type quux_type]
    end
  end
end
