require 'linode_cluster/node'
require 'linode_cluster/node_group'
require 'linode_cluster/client_wrapper'
require 'linode'

module LinodeCluster
  # Cluster class
  class Cluster
    attr_accessor :client, :ansible_ssh_user, :app_name, :stage

    def initialize(api_key, app_name, stage, options)
      @node_groups = {}
      @app_name = app_name || ''
      @stage = stage || ''
      @client = ClientWrapper.new(Linode.new(api_key: api_key))
      @ansible_ssh_user = options[:ansible_ssh_user] || 'root'

      raise 'app name cannot be blank' if app_name.empty?
      raise 'stage cannot be blank' if stage.empty?
    end

    def add_node_group(name, region, size, count, options = {})
      raise "Group with name '#{name}' already exists" if @node_groups[name]
      @node_groups[name] = NodeGroup.new(name, name_prefix, region, size, count, self, default_options(options))
    end

    def create!
      @node_groups.each_value(&:create!)
    end

    def name_prefix
      "#{app_name}-#{stage}-"
    end

    def as_ansible_inventory
      @node_groups.map { |_, group| group.as_ansible_inventory }.join
    end

    def nodes
      @node_groups.values.flat_map(&:nodes)
    end

    def cost_per_month
      nodes.map(&:cost_per_month).sum
    end

    def create_node(attributes)
      result = node_factory.create(attributes)
      @nodes = nil
      result
    end

    private

    def node_factory
      NodeFactory.new(client)
    end

    def default_options(options)
      actual_options = options.dup
      actual_options[:ansible_ssh_user] ||= ansible_ssh_user
      actual_options[:ansible_ssh_host] ||= '{{ ip_address }}'
      actual_options
    end
  end
end
