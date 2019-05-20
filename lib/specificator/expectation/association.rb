module Specificator::Expectation
  class Association

    ASSOCIATIONS_MAPPING = {
      has_many: :have_many,
      belongs_to: :belong_to,
      has_one: :have_one,
      has_and_belongs_to_many: :have_and_belong_to_many
    }

    OPTIONS_MAPPING = {
      class_name: :class_name,
      primary_key: :with_primary_key,
      foreign_key: :with_foreign_key,
      dependent: :dependent,
      counter_cache: :counter_cache,
      optional: :optional
    }

    attr_accessor :association

    def self.for(association)
      new(association).call
    end

    def initialize(association)
      @association = association
    end

    def call
      return unless valid?

      expectations.map{ |expectation| "it { should #{expectation} }" }
    end

    def valid?
      association_type.present?
    end

    private

    def expectations
      expectation_base = "#{association_type}(#{association.name.inspect})"

      options_expectations = association.options.map do |name, value|
        next unless (matcher_function = OPTIONS_MAPPING[name])

        if !!value == value
          expectation_base + ".#{matcher_function}"
        else
          expectation_base + ".#{matcher_function}(#{value.inspect})"
        end
      end

      (options_expectations.presence || [expectation_base]).flatten.compact
    end

    def association_type
      return @association_type if defined?(@association_type)
      type = association.class.to_s.match(/(\w+)Reflection$/)[1]&.underscore&.to_sym
      @association_type = ASSOCIATIONS_MAPPING[type]
    end

  end
end
