gem "rspec", "~> 2.4"
require "rspec"
require "has_many_scored/version"

require "pry"
require "active_record"
require "fakeredis"
require "redis-objects"

include HasManyScored

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Schema.verbose = false

def setup_db(&block)
  # AR caches columns options like defaults etc. Clear them!
  ActiveRecord::Base.connection.schema_cache.clear!
  ActiveRecord::Schema.define(version: 1, &block)

  Redis.current.flushall
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end
