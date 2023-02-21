# frozen_string_literal: true

require 'test_helper'

class DeployPin::Runner::Test < ActiveSupport::TestCase
  setup do
    DeployPin.setup do
      tasks_path './tmp/'
      groups %w[I II III post]
      fallback_group 'I'
      statement_timeout 0.2.second # 200 ms
      deployment_state_transition({
                                    ongoing: %w[I III],
                                    pending: 'post',
                                    ttl: 0.01.second
                                  })
    end
  end

  test 'deployment_tasks_code' do
    assert_nothing_raised do
      DeployPin.deployment_tasks_code
    end
  end

  test 'ongoing_deployment?' do
    assert_nothing_raised do
      DeployPin.ongoing_deployment?
    end
  end

  test 'pending_deployment?' do
    assert_nothing_raised do
      DeployPin.pending_deployment?
    end
  end

  test 'state transition' do
    assert_equal(false, DeployPin.ongoing_deployment?)
    assert_equal(false, DeployPin.pending_deployment?)
    sleep(0.02)
    eval(DeployPin.deployment_tasks_code[0])
    assert_equal(true, DeployPin.ongoing_deployment?)
    assert_equal(false, DeployPin.pending_deployment?)
    eval(DeployPin.deployment_tasks_code[1])
    sleep(0.02)
    assert_equal(false, DeployPin.ongoing_deployment?)
    assert_equal(false, DeployPin.pending_deployment?)
    eval(DeployPin.deployment_tasks_code[2])
    sleep(0.02)
    assert_equal(false, DeployPin.ongoing_deployment?)
    assert_equal(true, DeployPin.pending_deployment?)
  end

  teardown do
    # clean
    DeployPin::Record.delete_all
    ::FileUtils.rm_rf(DeployPin.tasks_path, secure: true)
  end
end
