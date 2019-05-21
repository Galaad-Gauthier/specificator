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

      "it { should #{expectation} } #{Specificator::Generator::WATERMARK}"
    end

    def valid?
      association_type.present?
    end

    private

    def expectation
      expectation = "#{association_type}(#{association.name.inspect})"

      association.options.each do |name, value|
        next unless (matcher_function = OPTIONS_MAPPING[name])

        if !!value == value
          expectation += ".#{matcher_function}"
        else
          expectation += ".#{matcher_function}(#{value.inspect})"
        end
      end

      expectation
    end

    def association_type
      ASSOCIATIONS_MAPPING[association.macro]
    end

  end
end
