require "has_many_scored/version"
require "has_many_scored/has_many_scored_extension"

module HasManyScored
  module ClassMethods
    def has_many_scored(name, opts=nil)
      opts = opts.try(:dup) || {}

      habtm_opts = opts.select { |k, v|
        [:class_name, :join_table, :foreign_key, :association_foreign_key,
         :readonly, :validate, :autosave].include?(k)
      }
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
      undef_method("#{name.to_s.singularize}_ids=")
      class_eval  <<-CODE, __FILE__, __LINE__ + 1
        def #{name}=(value)
          scope = association(:#{name}).scope
          value = value.sort_by { |v| scope.compute_score(v) }.reverse
                              puts value.map(&:name)
          super(value)
        end
      CODE
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
