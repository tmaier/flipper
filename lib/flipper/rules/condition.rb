require 'flipper/rules/rule'
require 'flipper/rules/properties'

module Flipper
  module Rules
    class Condition < Rule
      def self.build(hash)
        new(hash.fetch("left"), hash.fetch("operator"), hash.fetch("right"))
      end

      attr_reader :left, :operator, :right

      def initialize(left, operator, right)
        @left = Object.build(left)
        @operator = Operator.build(operator)
        @right = Object.build(right)
      end

      def all
        Flipper::Rules::All.new(self)
      end

      def any
        Flipper::Rules::Any.new(self)
      end

      def add(*rules)
        any.add(*rules)
      end

      def remove(*rules)
        any.remove(*rules)
      end

      def value
        {
          "type" => "Condition",
          "value" => {
            "left" => @left.to_h,
            "operator" => @operator.to_h,
            "right" => @right.to_h,
          }
        }
      end

      def eql?(other)
        self.class.eql?(other.class) &&
          @left == other.left &&
          @operator == other.operator &&
          @right == other.right
      end
      alias_method :==, :eql?

      def matches?(feature_name, actor = nil)
        properties = Properties.from_actor(actor)
        left_value = @left.evaluate(properties)
        right_value = @right.evaluate(properties)
        !!@operator.call(left: left_value, right: right_value, feature_name: feature_name)
      end
    end
  end
end
