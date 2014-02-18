module HasManyScored
  # This module is used to extend the join model and mix in additional logic
  module ScoredForManyExtension
    def self.bind_extension(options)
      return Module.new do
        include HasManyScored::ScoredForManyExtension

        # Options is defined using define_method so opts can still be within scope.
        define_method :options do
          return options
        end
      end
    end

    def update_score(*records)
      join_table = proxy_association.join_table
      reflection = proxy_association.reflection

      records.each do |record|
        update_manager = Arel::UpdateManager.new(join_table.engine)
        update_manager.table(join_table)\
          .set(join_table[options[:score_column]] => self.compute_score(proxy_association.owner))\
          .where(join_table[reflection.foreign_key].eq(proxy_association.owner.id))\
          .where(join_table[reflection.association_foreign_key].eq(record.id))\
          .take(1)
        sql = update_manager.to_sql
        puts sql
        puts proxy_association.owner.connection.execute(sql)
      end

      reset

      self
    end

    def compute_score(record)
      record.send(options[:score_field])
    end
  end
end
