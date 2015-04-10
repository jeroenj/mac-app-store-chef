# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_mac_app_store'

describe Chef::Resource::MacAppStore do
  %i(username password).each { |i| let(i) { nil } }
  let(:resource) do
    r = described_class.new(nil)
    %i(username password).each do |a|
      r.send(a, send(a))
    end
    r
  end

  shared_examples_for 'an invalid configuration' do
    it 'raises an exception' do
      expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end

  describe '#initialize' do
    it 'sets the correct resource name' do
      exp = :mac_app_store
      expect(resource.instance_variable_get(:@resource_name)).to eq(exp)
    end

    it 'sets the correct supported actions' do
      expected = [:nothing, :open, :quit]
      expect(resource.instance_variable_get(:@allowed_actions)).to eq(expected)
    end

    it 'defaults the running state to nil' do
      expect(resource.instance_variable_get(:@running)).to eq(nil)
    end

    it 'defaults the Apple ID to nil' do
      expect(resource.instance_variable_get(:@username)).to eq(nil)
      expect(resource.instance_variable_get(:@password)).to eq(nil)
    end
  end

  [:running, :running?].each do |m|
    describe "##{m}" do
      context 'default unknown running state' do
        it 'returns nil' do
          expect(resource.send(m)).to eq(nil)
        end
      end

      context 'App Store running' do
        it 'returns true' do
          r = resource
          r.instance_variable_set(:@running, true)
          expect(r.send(m)).to eq(true)
        end
      end

      context 'App Store not running' do
        it 'returns false' do
          r = resource
          r.instance_variable_set(:@running, false)
          expect(resource.send(m)).to eq(false)
        end
      end
    end
  end

  describe '#username' do
    context 'no override' do
      it 'returns the default' do
        expect(resource.username).to eq(nil)
      end
    end

    context 'a valid override' do
      let(:username) { 'example' }

      it 'returns the override' do
        expect(resource.username).to eq('example')
      end
    end

    context 'an invalid override' do
      let(:username) { [1, 2, 3] }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#password' do
    context 'no override' do
      it 'returns the default' do
        expect(resource.password).to eq(nil)
      end
    end

    context 'a valid override' do
      let(:password) { 'example' }

      it 'returns the override' do
        expect(resource.password).to eq('example')
      end
    end

    context 'an invalid override' do
      let(:password) { [1, 2, 3] }

      it_behaves_like 'an invalid configuration'
    end
  end

  describe '#to_text' do
    let(:password) { 'abc123' }

    it 'suppresses the password in the resource rendered text' do
      expect(resource.to_text).to include('password "****************"')
    end
  end
end