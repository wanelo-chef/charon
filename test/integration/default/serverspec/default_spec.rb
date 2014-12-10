require 'spec_helper'

RSpec.describe 'charon::default' do
  describe user('ftpd') do
    it { should exist }
  end

  describe service('charon') do
    it { should be_running }
  end
end
