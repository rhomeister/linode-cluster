module LinodeCluster
  # Client Wrapper class
  class ClientWrapper
    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def linode
      client.linode
    end

    def nodes
      @nodes ||= begin
        ip_addresses = client.linode.ip.list
        linodes = client.linode.list

        linodes.map do |l|
          node = Node.new(l, self)
          node.ip_address = ip_addresses.find { |i| i.linodeid == node.linodeid }.ipaddress
          node
        end
      end
    end

    def find_node_by_name(name)
      node_by_name = nodes.select { |d| d.label == name }
      raise "Found multiple nodes with name #{name}" if node_by_name.count > 1
      node_by_name.first
    end

    def find_node_by_id(id)
      node_by_id = nodes.select { |d| d.linodeid == id }
      raise "Found multiple nodes with id #{id}" if node_by_id.count > 1
      node_by_id.first
    end

    def refresh_nodes
      @nodes = nil
      nodes
    end

    def find_datacenter_id(region)
      datacenters.find { |d| d.abbr == region }.datacenterid
    end

    def find_datacenter_by_id(id)
      datacenters.find { |d| d.datacenterid == id }
    end

    def find_plan_id(size)
      plans.find { |p| p.ram.to_s == size.to_s }.planid
    end

    def find_plan_by_id(id)
      plans.find { |p| p.planid == id }
    end

    def find_distribution_id_by_name(name)
      distributions.find { |p| p.label == name }.distributionid
    end

    def find_default_kernel
      kernels.find { |k| k.label.include?('Latest 64') }
    end

    private

    def datacenters
      @datacenters ||= client.avail.datacenters
    end

    def plans
      @plans ||= client.avail.linodeplans
    end

    def distributions
      @distributions ||= client.avail.distributions
    end

    def kernels
      @kernels ||= client.avail.kernels
    end
  end
end
