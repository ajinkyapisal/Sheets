module Sheets
  module Parseable
    include Enumerable
    
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def formats
        Sheets::Parsers.constants.collect {|constant_name| Sheets::Parsers.const_get(constant_name) }.map(&:formats).flatten.uniq
      end
    end

    def each
      to_array.each {|row| yield row }
    end

    [ :to_array, :to_csv ].each do |method_name|
      define_method(method_name) do
        parser.send(method_name)
      end
    end

    private
    def parser_class
      classes = Sheets::Parsers.constants.map do |constant_name|
        constant = Sheets::Parsers.const_get(constant_name)
        constant if constant && constant.respond_to?(:formats) && constant.formats.map(&:to_s).include?(@extension)
      end

      classes.delete(nil)

      classes.first
    end

    def parser
      @parser ||= parser_class.new(@data, @extension) unless parser_class.nil?
    end
  end
end