require 'spec_helper'

describe 'peadm::subplans::preinstall' do
  # Include the BoltSpec library functions
  include BoltSpec::Plans

  before(:each) do
    allow_any_task
    allow_any_plan
    allow_any_command
    allow_apply
  end

  it 'minimum variables to run' do
    params = {
      'primary_host' => 'primary',
    }

    expect(run_plan('peadm::subplans::preinstall', params)).to be_ok
  end
end
