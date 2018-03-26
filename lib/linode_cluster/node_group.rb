# frozen_string_literal: true

module LinodeCluster
  NodeGroup = Struct.new(:name, :group_name_prefix, :region, :size, :count, :image_name, :cluster, :options) do
    def names
      Array.new(count) { |i| "#{name_prefix}#{i}" }
    end

    def name_prefix
      "#{group_name}-"
    end

    def group_name
      "#{group_name_prefix}#{name}"
    end

    def create!
      names.each do |name|
        node = cluster.client.find_node_by_name(name)
        if node
          check_node_specs(node)
        else
          create_node(name)
        end
      end
    end

    def nodes
      names.map { |n| cluster.client.find_node_by_name(n) }.compact
    end

    def template_options(node)
      Hash[options.map do |k, v|
             v = node.ip_address if v == '{{ ip_address }}'
             [k, v]
           end]
    end

    def as_ansible_inventory
      result = +"[#{name}]\n"
      nodes.each do |node|
        string_options = template_options(node).map { |k, v| "#{k}=#{v}" }.join(' ')

        result << "#{node.name} #{string_options}".strip
        result << "\n"
      end
      result << "\n"
    end

    private

    def create_node(name)
      puts "Creating #{name}"
      cluster.create_node(name: name, region: region, size: size, group_name: group_name, image_name: image_name)
    end

    def check_node_specs(node)
      warnings = []

      if node.region.to_s != region.to_s
        warnings << "REGION: Expected #{region}, but got #{node.region}"
      end

      if node.size.to_s != size.to_s
        warnings << "SIZE:   Expected #{size}, but got #{node.size}"
      end

      if warnings.empty?
        puts "Node #{node.name}: EXISTS"
      else
        puts "Node #{node.name}: WARNING"
        warnings.each do |warning|
          puts '    ' + warning
        end
      end
    end
  end
end
