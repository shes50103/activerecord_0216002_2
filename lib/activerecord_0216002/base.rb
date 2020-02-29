module ActiveRecord
  class Base
    # "INSERT INTO users (name,phone,age) VALUES ('Ancestor', '0932445631', '12')"
    # "SELECT column_name FROM information_schema.columns WHERE table_name= 'users'"

    def initialize(attributes)
      self.class.set_columns
      @attributes = attributes
      @new_record = true
    end

    def save
      if new_record?
        sql = "INSERT INTO users (#{@attributes.keys.join(',')}) VALUES ('#{@attributes.values.join("','")}')"
        self.class.connection.execute(sql)
        @new_record = false
        true
      else
        false
      end
    end

    def new_record?
      @new_record
    end



    class << self
      #0
      def establish_connection(option)
        case option[:adapter]
        when 'postgresql'
          @@connection = ConnectionAdapter::PostgreSQLAdapter.new(option[:database])
        when 'sqlite'
          #TODO
        end
      end

      #0
      def connection
        @@connection
      end

      def set_columns
        pg_result = ActiveRecord::Base.connection.execute("SELECT column_name FROM information_schema.columns WHERE table_name= 'users'")

        pg_result.map{|hash| hash['column_name']}.each do |name|
          define_attr_method(name)
        end
      end

      def define_attr_method(name)
        define_method name do
          @attributes["#{name}"] || @attributes[name.to_sym]
        end

        define_method "#{name}=" do |value|
          @attributes[name] = value
        end
      end

      def all
        find_by_sql("SELECT * FROM users")
      end

      def last
        all.last
      end

      def first
        all.first
      end


      def find(id)
        find_by_sql("SELECT * FROM users WHERE id=#{id}").first
      end

      def find_by_sql(sql)
        self.connection.execute(sql).map do |h|
          new(h)
        end
      end
    end
  end
end