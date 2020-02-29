module ActiveRecord
  class Base
    # "INSERT INTO users (name,phone,age) VALUES ('Ancestor', '0932445631', '12')"
    # "SELECT column_name FROM information_schema.columns WHERE table_name= 'users'"

    def initialize(attributes)
      self.class.set_columns
      @attributes = attributes
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
          @attributes[name] || @attributes[name.to_sym]
        end

        define_method "#{name}=" do |value|
          @attributes[name] = value
        end
      end
    end
  end
end