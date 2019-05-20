class SharedExamplesGenerator::ValidationsExpectations

  PERMITTED_VALIDATOR_TYPES = %w(
    absence acceptance confirmation exclusion inclusion
    length numericality presence uniqueness
  )

  OPTIONS_MAPPING = {
    minimum: :is_at_least,
    maximum: :is_at_most,
    on: :on,
    message: :with_message,
    in: :in_array,
    is: :is_equal_to,
    equal_to: :is_equal_to,
    too_short: :with_short_message,
    long_message: :with_long_message,
    allow_nil: :allow_nil,
    only_integer: :only_integer,
    less_than: :is_less_than,
    less_than_or_equal_to: :is_less_than_or_equal_to,
    greater_than_or_equal_to: :is_greater_than_or_equal_to,
    greater_than: :is_greater_than,
    even: :even,
    odd: :odd,
    scope: :scoped_to
  }

  attr_accessor :model_class

  def self.for(model_class)
    new(model_class).call
  end

  def initialize(model_class)
    @model_class = model_class
  end

  def call
    expectations.map{ |expectation| "it { #{expectation} }" }
  end

  private

  def expectations
    model_class.validators.map do |validator|
      validator_type = validator_type_for(validator)
      next unless validator_type.in?(PERMITTED_VALIDATOR_TYPES)

      validator.attributes.map do |attribute|
        expectation_base = "should validate_#{validator_type}_of(#{attribute.inspect})"

        options_expectations = validator.options.map do |name, value|
          next unless (matcher_function = OPTIONS_MAPPING[name])
          expectation_base + ".#{matcher_function}(#{value.inspect})"
        end

        options_expectations.presence || expectation_base
      end
    end.flatten.compact
  end

  def validator_type_for(validator)
    validator.class.to_s.match(/(\w+)Validator$/)[1]&.downcase
  end

end
