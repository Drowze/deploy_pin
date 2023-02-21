# frozen_string_literal: true

require 'deploy_pin/deployment_state'
require 'deploy_pin/runner'
require 'deploy_pin/collector'
require 'deploy_pin/parallel_wrapper'
require 'deploy_pin/task'
require 'deploy_pin/task_criteria'
require 'deploy_pin/engine'
require 'deploy_pin/database'
require 'parallel'
require 'ruby-progressbar'
require 'colorize'

module DeployPin
  OPTIONS = %i[
    tasks_path
    fallback_group
    groups
    statement_timeout
    run_formatter
    list_formatter
    deployment_state_transition
  ].freeze

  OPTIONS.each do |option|
    instance_eval %{
      def #{option}(val = nil)
        return @@#{option} unless val.present?

        @@#{option} = val
      end
    }, __FILE__, __LINE__ - 6
  end

  def self.setup(&block)
    instance_eval(&block)
  end

  def self.enabled?(option)
    class_variable_defined?("@@#{option}")
  end
end
