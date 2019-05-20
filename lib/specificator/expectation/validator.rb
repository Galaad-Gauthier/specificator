module Specificator::Expectation
  class Validator

    OPTIONS_MAPPING = {
      absence: {
        on: :on,
        message: :with_message,
      },

      acceptance: {
        on: :on,
        message: :with_message,
      },

      confirmation: {
        on: :on,
        message: :with_message,
      },

      exclusion: {
        on: :on,
        message: :with_message,
      },

      inclusion: {
        on: :on,
        message: :with_message,
        # allow_nil: :allow_nil, Still some issues
        # allow_blank: :allow_blank, Still some issues
        in: {
          Range => :in_range,
          Array => :in_array
        }
      },

      length: {
        on: :on,
        minimum: :is_at_least,
        maximum: :is_at_most,
        in: :in,
        is: :is_equal_to,
        message: :with_message,
        too_short: :with_short_message,
        long_message: :with_long_message,
        # allow_nil: :allow_nil, Still some issues
      },

      numericality: {
        on: :on,
        only_integer: :only_integer,
        less_than: :is_less_than,
        less_than_or_equal_to: :is_less_than_or_equal_to,
        greater_than_or_equal_to: :is_greater_than_or_equal_to,
        equal_to: :is_equal_to,
        greater_than: :is_greater_than,
        even: :even,
        odd: :odd,
        allow_nil: :allow_nil
      },

      presence: {
        on: :on,
        message: :with_message
      },

      uniqueness: {
        on: :on,
        message: :with_message,
        scope: :scoped_to,
        # allow_nil: :allow_nil, Still some issues
        # allow_blank: :allow_blank, Still some issues
      }
    }

    attr_accessor :validator

    def self.for(validator)
      new(validator).call
    end

    def initialize(validator)
      @validator = validator
    end

    def call
      return unless valid?

      expectations.map{ |expectation| "it { should #{expectation} }" }
    end

    def valid?
      validator_kind.in?(OPTIONS_MAPPING.keys)
    end

    private

    def expectations
      validator.attributes.map do |attribute|
        expectation_base = "validate_#{validator_kind}_of(#{attribute.inspect})"

        options_expectations = validator.options.map do |name, value|
          next unless (matcher_function = matcher_function_for(name, value))

          if !!value == value
            expectation_base + ".#{matcher_function}"
          else
            expectation_base + ".#{matcher_function}(#{value.inspect})"
          end
        end.flatten.compact

        options_expectations.presence || expectation_base
      end.flatten.compact
    end

    def validator_kind
      validator.kind
    end

    def matcher_function_for(name, value)
      matcher_function = OPTIONS_MAPPING[validator_kind][name]
      matcher_function.is_a?(Hash) ? matcher_function[value.class] : matcher_function
    end

  end
end
