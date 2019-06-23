appraise "5.2" do
  gem "activerecord", "~> 5.2"
end

appraise "5.1" do
  gem "activerecord", ">= 5.1.0", "< 5.2.0"
end

appraise "5.0" do
  gem "activerecord", ">= 5.0.0", "< 5.1.0"
  gem "i18n", "1.5.1"
end

appraise "4.2" do
  gem "activerecord", ">= 4.2.0", "< 5.0.0"
  gem "i18n", "~> 0.7"
  gem "pg", "~> 0.15"
end

appraise "4.1" do
  gem "activerecord", ">= 4.1.0", "< 4.2.0"
  gem "i18n", "~> 0.7"
  gem "pg", "~> 0.15"
end

appraise "edge" do
  gem "rails", git: "https://github.com/rails/rails.git", branch: "master"
end
