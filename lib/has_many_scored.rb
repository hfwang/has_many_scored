require "has_many_scored/version"
require "has_many_scored/has_many_scored_extension"
require "has_many_scored/scored_for_many_extension"

module HasManyScored
  module ClassMethods
    VALID_HABTM_OPTIONS = [:class_name, :join_table, :foreign_key,
                           :association_foreign_key, :readonly, :validate,
                           :autosave]

    def has_many_scored(name, opts=nil)
      opts = opts.try(:dup) || {}

      habtm_opts = opts.select { |k, v| VALID_HABTM_OPTIONS.include?(k) }
      habtm_opts[:insert_sql] = lambda { |record|
        proxy_association = self.association(name)
        join_table = proxy_association.join_table
        reflection = proxy_association.reflection

        return join_table.compile_insert(
          join_table[reflection.foreign_key] => self.id,
          join_table[reflection.association_foreign_key] => record.id,
          join_table[opts[:score_column]] => proxy_association.scope.compute_score(record))
      }

      opts[:score_column] ||= :score
      opts[:score_field] ||= :score

      habtm = has_and_belongs_to_many(
        name,
        lambda { order('score DESC').extending(HasManyScored::HasManyScoredExtension.bind_extension(opts)) },
        habtm_opts)
    end

    def scored_for_many(name, opts=nil)
      opts = opts.try(:dup) || {}

      habtm_opts = opts.select { |k, v| VALID_HABTM_OPTIONS.include?(k) }
      habtm_opts[:insert_sql] = lambda { |record|
        proxy_association = self.association(name)
        join_table = proxy_association.join_table
        reflection = proxy_association.reflection

        return join_table.compile_insert(
          join_table[reflection.foreign_key] => self.id,
          join_table[reflection.association_foreign_key] => record.id,
          join_table[opts[:score_column]] => proxy_association.scope.compute_score(self))
      }

      opts[:score_column] ||= :score
      opts[:score_field] ||= :score

      habtm = has_and_belongs_to_many(
        name,
        lambda { order('score DESC').extending(HasManyScored::ScoredForManyExtension.bind_extension(opts)) },
        habtm_opts)
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
