Puppet::Type.newtype(:bsd_interface) do
  @doc = "Manage a network interface state on BSD"

  newparam :name, :namevar => true

  ensurable do
    desc("The state the interface should be in.")

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    newvalue(:up) do
      provider.up
    end

    newvalue(:down) do
      provider.down
    end

    aliasvalue(:down, :absent)
    aliasvalue(:up, :present)

    defaultto :present
  end

  newparam :parents do
    desc "a String or Array of parent interfaces"
    validate do |value|
      if value.is_a? Array
        value.each { |v|
          if ! v.match(/[[:alpha:]]+[[:digit:]]+/)
            raise ArgumentError, "got illegal parent interface: '#{v}' for '#{resource[:name]}'"
          end
        }
      elsif value.is_a? String
        if ! value.match(/[[:alpha:]]+[[:digit:]]+/)
          raise ArgumentError, "got illegal parent interface: '#{value}' for '#{resource[:name]}'"
        end
      else
        raise ArgumentError, "parents can only be a String or an Array, is: #{value.class}"
      end
    end
  end

  newproperty(:state) do
    desc "The state of the interface"
    newvalue(:up)
    newvalue(:down)
    newvalue(:absent)
  end

  newproperty(:destroyable) do
    desc "Booleana representing if the interface is a pseudo interface"
    newvalue(:true)
    newvalue(:false)
  end

  newproperty(:flags) do
    desc "Interface flags from ifconfig(8)"
  end

  newproperty(:mtu) do
    desc "Running MTU of the interface"
  end

  def refresh
    provider.restart
  end

  autorequire(:bsd_interface) do
    self[:parents]
  end

end
