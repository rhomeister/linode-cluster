# frozen_string_literal: true

module LinodeCluster
  # node factory class
  class NodeFactory
    # DEFAULT_IMAGE_NAME = 'Ubuntu 16.04 LTS'.freeze
    DEFAULT_IMAGE_NAME = 'Ubuntu 14.04 LTS'.freeze

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def find_datacenter_id
      client.find_datacenter_id
    end

    def find_plan_id
      client.find_plan_id
    end

    def find_node_by_id
      client.find_node_by_id
    end

    def refresh_nodes
      client.refresh_nodes
    end

    def find_distribution_id_by_name
      client.find_distribution_id_by_name
    end

    def find_default_kernel
      client.find_default_kernel
    end

    def create(attributes)
      linode_attributes = { datacenterid: find_datacenter_id(attributes[:region]),
                            planid: find_plan_id(attributes[:size]) }

      result = client.linode.create(linode_attributes)

      begin
        client.linode.update(linodeid: result.linodeid,
                             label: attributes[:name],
                             lpm_displaygroup: attributes[:group_name])

        swap_disk = client.linode.disk.create(
          linodeid: result.linodeid,
          type: 'swap',
          label: 'Swap',
          size: 512
        )

        # need to fetch data about the new node to calculate the size of the new disk
        refresh_nodes
        new_node = find_node_by_id(result.linodeid)

        os_disk = client.linode.disk.createfromdistribution(
          linodeid: result.linodeid,
          distributionid: find_distribution_id_by_name(DEFAULT_IMAGE_NAME),
          label: DEFAULT_IMAGE_NAME,
          rootpass: SecureRandom.hex,
          size: new_node.totalhd - 512,
          rootsshkey: File.read('/home/rs06r/.ssh/id_rsa.pub')
        )

        client.linode.config.create(
          linodeid: result.linodeid,
          label: 'default',
          kernelid: find_default_kernel.kernelid,
          disklist: [os_disk.diskid, swap_disk.diskid].join(',')
        )

        client.linode.boot(linodeid: result.linodeid)
        new_node
      rescue StandardError => e
        client.linode.delete(linodeid: result.linodeid, skipchecks: true)
        raise e
      end
    end
  end
end
