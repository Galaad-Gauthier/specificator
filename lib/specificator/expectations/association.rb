class Specificator::Expectations::Association

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
    model_class.reflect_on_all_associations.map do |association|
      next unless association_type = association_type_for(association)

      expectation_base = "should #{association_type}(#{association.name.inspect})"

      options_expectations = association.options.map do |name, value|
        next unless (matcher_function = OPTIONS_MAPPING[name])
        expectation_base + ".#{matcher_function}(#{value.inspect})"
      end

      options_expectations.presence || expectation_base
    end.flatten.compact
  end

  def association_type_for(association)
    type = association.class.to_s.match(/(\w+)Reflection$/)[1]&.underscore&.to_sym
    ASSOCIATIONS_MAPPING[type]
  end

end
