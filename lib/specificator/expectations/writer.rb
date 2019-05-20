module SharedExamplesGenerator
  class Writer

    GENERATOR_WATERMARK = "# Generated by SharedExamplesGenerator"

    attr_accessor :model_name, :model_class

    def initialize(model_name)
      @model_name = model_name
      @model_class = model_name.capitalize.constantize
    end

    def call
      return unless model_class < ActiveRecord::Base

      shared_spec_path = File.join(Rails.root, 'spec', 'support', "#{model_name.downcase}_shared.rb")

      File.open(shared_spec_path, 'w') do |file|
        file.write GENERATOR_WATERMARK + "\n"
        file.write shared_examples_for(validation_expectations, "#{model_name.downcase}_validations")
        file.write shared_examples_for(associations_expectations, "#{model_name.downcase}_associations")
      end
    end

    private

    def validation_expectations
      ValidationsExpectations.for(model_class)
    end

    def associations_expectations
      AssociationsExpectations.for(model_class)
    end

    # model_spec_path = File.join(Rails.root, 'spec', 'models', "#{model_name.downcase}_spec.rb")

    def shared_examples_for(expectations, type)
      <<~EOS
       \nRSpec.shared_examples "#{type}" do
         #{expectations.join("\n  ")}
       end
      EOS
    end

  end
end
