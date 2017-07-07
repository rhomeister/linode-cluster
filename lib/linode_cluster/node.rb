module LinodeCluster
  # Node class
  class Node < Delegator
    attr_accessor :ip_address, :client

    def initialize(obj, client)
      super obj # pass obj to Delegator constructor, required
      @delegate_sd_obj = obj # store obj for future use
      @client = client
    end

    def __getobj__
      @delegate_sd_obj # return object we are delegating to, required
    end

    def __setobj__(obj)
      @delegate_sd_obj = obj
    end

    def region
      client.find_datacenter_by_id(datacenterid).abbr
    end

    def size
      return nil if plan.nil?
      plan.ram
    end

    def name
      label
    end

    def plan
      client.find_plan_by_id(planid)
    end

    def cost_per_month
      plan.price
    end
  end
end
