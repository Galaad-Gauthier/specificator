require "specificator/version"
require "specificator/expectation/association"
require "specificator/expectation/validation"

module Specificator
  class Error < StandardError; end

  class Generator
    WATERMARK = " # Specificator"
    EXPECTATIONS_TYPES = %w(validations associations).freeze

    attr_accessor :model_class

    def self.generate_for(model_class)
      new(model_class).generate
    end

    def initialize(model_class)
      @model_class = model_class
    end

    def generate
      return unless valid?

      prepare_model_specs! || update_model_specs!
    end

    def valid?
      model_class < ActiveRecord::Base
    end

    private

    def validations_expectations
      @validations_expectations ||= model_class.validators.map do |validator|
        Expectation::Validation.for(validator)
      end.flatten.compact
    end

    def associations_expectations
      @associations_expectations ||= model_class.reflect_on_all_associations.map do |association|
        Expectation::Association.for(association)
      end.flatten.compact
    end

    def describe_block_for(expectations, type)
      prepared_expectations = expectations.map do |expectation|
        "\t\t#{expectation.strip}"
      end

      <<~EOS
       \n\tdescribe "#{type}" do
        #{prepared_expectations.join("\n")}
       \tend
      EOS
    end

    def model_spec_path
      File.join(Rails.root, 'spec', 'models', "#{model_name.downcase}_spec.rb")
    end

    def model_name
      model_class.name.underscore
    end

    def file_data
      @file_data ||= File.read(model_spec_path)
    end

    def missing_types
      @missing_types ||= EXPECTATIONS_TYPES.reject do |type|
        file_data.match(/describe\s\"#{type}\"/)
      end
    end

    def prepare_model_specs!
      return false unless missing_types.any?

      File.open(model_spec_path, 'r+') do |file|
        File.foreach(model_spec_path) do |line|
          file.puts line
          if line =~ /RSpec\.describe/
            missing_types.each do |type|
              file.puts describe_block_for(send("#{type}_expectations"), type)
            end
          end
        end
      end
      true
    end

    def update_model_specs!
      File.open(model_spec_path, 'w+') do |file|
        describe_blocks = file_data.scan(/(describe\s+\"(\w+)\".*?end$)/m).map do |block, block_type|
          [block, block_type, block.split("\n")]
        end

        describe_blocks.each do |block, block_type, lines|
          next unless block_type.in? EXPECTATIONS_TYPES

          custom_lines = lines[1..-2].to_a # Removing block definition lines
          custom_lines.reject!{ |line| line.match(/#{WATERMARK}/) }
          custom_lines.map!(&:strip)

          expectations = send("#{block_type}_expectations")
          new_block = describe_block_for(custom_lines + expectations, block_type)

          file_data.sub!(block.strip, new_block.strip)
        end

        file.write(file_data)
      end
    end

  end
end
