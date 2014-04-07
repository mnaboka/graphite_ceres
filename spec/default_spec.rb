require 'spec_helper'

describe 'graphite_ceres::user' do
    let(:runner) do
        ChefSpec::Runner.new do |node|
            # Mocking attributes

            # Create a new environment (you could also use a different :let block or :before block)
            env = Chef::Environment.new

            # Stub the node to return this environment
            node.stub(:chef_environment).and_return(env.name)
            # Stub any calls to Environment.load to return this environment
            Chef::Environment.stub(:load).and_return(env)
        end
    end

    before do
    #    # stub search and data bags here if needed
    end
end
