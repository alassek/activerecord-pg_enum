require "spec_helper"

RSpec.describe "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter" do
  subject { connection }

  it { is_expected.to respond_to :enum_types }

  context "with multiple types defined" do
    before :each do
      execute "CREATE TYPE quux_type AS ENUM ('quux')"
      execute "CREATE TYPE baz_type AS ENUM ('baz')"
      execute "CREATE TYPE bar_type AS ENUM ('bar')"
      execute "CREATE TYPE foo_bar_type AS ENUM ('foo bar')"
    end

    after :each do
      execute "DROP TYPE quux_type"
      execute "DROP TYPE baz_type"
      execute "DROP TYPE bar_type"
      execute "DROP TYPE foo_bar_type"
    end

    it "lists types in alphabetical order" do
      expect(subject.enum_types.keys).to eq %w[bar_type baz_type foo_bar_type quux_type]
    end

    it "deserializes the types correctly" do
      expect(subject.enum_types.values).to match_array [['quux'], ['baz'], ['bar'], ['foo bar']]
    end
  end
end
