require 'spec_helper'
require 'has_many_scored'

class Topic2 < ActiveRecord::Base
  include HasManyScored
  scored_for_many :tags, class_name: "Tag2", score_column: :hotness, score_field: :compute_hotness do
    def custom_method
      return true
    end
  end

  def compute_hotness
    create_ts
  end
end
class Tag2 < ActiveRecord::Base
  include HasManyScored
  has_many_scored :topics, class_name: "Topic2", score_column: :hotness, score_field: :compute_hotness do
    def custom_other_method
      return true
    end
  end
end

def setup_schema2!
  setup_db do
    create_table :topic2s do |t|
      t.column :name, :string
      t.column :create_ts, :integer
    end
    create_table :tag2s do |t|
      t.column :name, :string
    end
    create_table :tag2s_topic2s do |t|
      t.column :topic2_id, :integer
      t.column :tag2_id, :integer
      t.column :hotness, :integer
    end
  end
end

BASE_TIME = Time.now.to_i
describe Tag2 do
  before(:each) do
    setup_schema2!
  end
  after(:each) do
    teardown_db
  end
  context "with dummy data" do
    before do
      @t1 = Topic2.create(:name => "Topic 1", :create_ts => BASE_TIME + 2)
      @t2 = Topic2.create(:name => "Topic 2", :create_ts => BASE_TIME + 1)
      @t3 = Topic2.create(:name => "Topic 3", :create_ts => BASE_TIME + 3)
      @tag = Tag2.create(:name => "Tag 1")
      @tag.topics << @t1 << @t2 << @t3
    end

    it "computes size" do
      expect(@tag.topics.size).to eq(3)
      @tag.topics = []
      expect(@tag.topics.size).to eq(0)
    end

    it "computes score when setting by ID" do
      @tag.topic_ids = [@t1.id, @t2.id]
      expect(@tag.topics(true).map(&:name)).to eq(["Topic 1", "Topic 2"])

      @tag.topic_ids = [@t3.id]
      expect(@tag.topics(true).map(&:name)).to eq(["Topic 3"])

      @tag.topic_ids = [@t3.id, @t2.id, @t1.id]
      expect(@tag.topics(true).map { |t| t.name }).to eq(["Topic 3", "Topic 1", "Topic 2"])
    end

    it "computes scores" do
      expect(@tag.topics.compute_score(@t2)).to eq(BASE_TIME + 1)
    end

    it "reads in scored order" do
      # Sadly we have to call reload.
      @tag.topics.reload

      expect(@tag.topics.map { |t| t.name }).to eq(["Topic 3", "Topic 1", "Topic 2"])
      expect(@tag.topics.first(2).map { |t| t.name }).to eq(["Topic 3", "Topic 1"])
    end

    it "handles delete" do
      @tag.topics.delete(@t1)

      expect(@tag.topics.map { |t| t.name }).to eq(["Topic 3", "Topic 2"])
    end

    it "handles update_score" do
      @t2.create_ts = BASE_TIME + 4
      @t2.save
      @tag.topics.update_score(@t2)

      expect(Tag2.first.topics.map { |t| t.name }).to eq(["Topic 2", "Topic 3", "Topic 1"])
    end
  end
end

describe Topic2 do
  before(:each) do
    setup_schema2!
  end
  after(:each) do
    teardown_db
  end

  context "with dummy data" do
    before do
      @t1 = Topic2.create(:name => "Topic 1", :create_ts => BASE_TIME + 2)
      @t2 = Topic2.create(:name => "Topic 2", :create_ts => BASE_TIME + 1)
      @t3 = Topic2.create(:name => "Topic 3", :create_ts => BASE_TIME + 3)
      @tag1 = Tag2.create(:name => "Tag 1")
      @tag2 = Tag2.create(:name => "Tag 2")
      @tag2 = Tag2.create(:name => "Tag 3")
      @tag1.topics << @t2 << @t3
      @t1.tags << @tag1 << @tag2
    end

    it "computes size" do
      expect(@t1.tags.size).to eq(2)
      @t1.tags = []
      expect(@t1.tags.size).to eq(0)
    end

    it "reads in scored order" do
      # Sadly we have to call reload.
      @tag1.topics.reload

      expect(@tag1.topics.map { |t| t.name }).to eq(["Topic 3", "Topic 1", "Topic 2"])
      expect(@tag2.topics.map { |t| t.name }).to eq(["Topic 1"])
    end

    it "accepts block extensions" do
      expect(@t1.tags).to respond_to(:custom_method)
    end
  end
end
