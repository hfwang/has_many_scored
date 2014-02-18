require 'spec_helper'
require 'has_many_scored'

class Topic < ActiveRecord::Base
  include HasManyScored
  scored_for_many :tags
end
class Tag < ActiveRecord::Base
  include HasManyScored
  has_many_scored :topics
end

def setup_schema!
  setup_db do
    create_table :topics do |t|
      t.column :name, :string
      t.column :score, :float
    end
    create_table :tags do |t|
      t.column :name, :string
    end
    create_table :tags_topics do |t|
      t.column :topic_id, :integer
      t.column :tag_id, :integer
      t.column :score, :float
    end
  end
end

describe Tag do
  before(:each) do
    setup_schema!
  end
  after(:each) do
    teardown_db
  end
  context "with dummy data" do
    before do
      @t1 = Topic.create(:name => "Topic 1", :score => 0.2)
      @t2 = Topic.create(:name => "Topic 2", :score => 0.1)
      @t3 = Topic.create(:name => "Topic 3", :score => 0.3)
      @tag = Tag.create(:name => "Tag 1")
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
      expect(@tag.topics.compute_score(@t2)).to eq(0.1)
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
      @t2.score = 4.0
      @t2.save
      @tag.topics.update_score(@t2)

      expect(Tag.first.topics.map { |t| t.name }).to eq(["Topic 2", "Topic 3", "Topic 1"])
    end
  end
end

describe Topic do
  before(:each) do
    setup_schema!
  end
  after(:each) do
    teardown_db
  end

  context "with dummy data" do
    before do
      @t1 = Topic.create(:name => "Topic 1", :score => 0.2)
      @t2 = Topic.create(:name => "Topic 2", :score => 0.1)
      @t3 = Topic.create(:name => "Topic 3", :score => 0.3)
      @tag1 = Tag.create(:name => "Tag 1")
      @tag2 = Tag.create(:name => "Tag 2")
      @tag2 = Tag.create(:name => "Tag 3")
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
  end
end
