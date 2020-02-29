module ActiveRecord
  class Relation
    def initialize(klass)
      @klass = klass
      @where_values = []
    end

    def where(data)
      @where_values << data
      self
    end

    def first
      @klass.find_by_sql(sql).first
    end

    def sql
      sql = "SELECT * FROM users"
      if @where_values.any?
        sql += " WHERE " + @where_values.join(" AND ")
      end
      sql
    end
  end
end