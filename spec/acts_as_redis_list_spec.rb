require 'spec_helper'
require 'acts_as_redis_list'

describe ActsAsRedisList do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
