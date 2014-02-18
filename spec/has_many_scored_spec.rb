require 'spec_helper'
require 'has_many_scored'

describe HasManyScored do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
