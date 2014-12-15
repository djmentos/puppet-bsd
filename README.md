# Puppet BSD

[![Build Status](https://travis-ci.org/xaque208/puppet-bsd.png?branch=master)](https://travis-ci.org/xaque208/puppet-bsd)

A Puppet module for managing aspects of BSD.  Currently supported are FreeBSD
and OpenBSD.  In here will be various facts, functions and classes for tuning
and configuring a system.

It is intended that Puppet users of this code use only the classes and facts in
their manifests.  The rest of the code here is simply to support the interface
supplied by the manifests.  Implementing the functions directly is not advised,
as the implementation may shift over time as the module requires.

## Network

Network configuration is handled under the `bsd::network` name space.  Under
this space you will find classes available to configure basic network
configuration items like gateways and static address, to more advanced topics
like `vlan(4)` and `carp(4)` interfaces.

Ideally, this module should support any useful aspect of network configuration,
including things like wireless (AP and client) and static routes.

### Gateways

The gateway can be configured for both router and hosts.

#### host

To configure static addressing on a host, first you may wish to configure the
gateway(s).

```Puppet
class { 'bsd::network':
  v4gateway => '10.0.0.1',
  v6gateway => 'fc00::',
}
```

#### router

To set the upstream gateway on a router system as well as turn on dual stack
forwarding, use the following configuration.

```Puppet
class { 'bsd::network':
  v4gateway    => '1.1.1.1',
  v6gateway    => '2001:b:b::1',
  v4forwarding => true,
  v6forwarding => true,
}
```

### Addressing

Once you have the gateway set, you may wish to set some interface addresses.

```Puppet
bsd::network::interface { 'em0':
  description => 'Primary Interface',
  values      => [ '10.0.0.2/24', 'fc00::b0b/64' ],
}
```

This will do the needful of setting the configuration for setting the interface
address and gateway.

```
NOTE: This only sets the configuration, it does not currently set the running interfaces addresses.
```

### Interfaces

Interface configurations are handled per interface type.  Each supported type
will have an implementation of the library through the user of functions and
expose a manifest to the user for configuration.

#### vlan(4)

To create a `vlan(4)` interface and assign an address to it, use a manifest
like the following.

```Puppet
bsd::network::interface::vlan { 'vlan100':
  id      => '1',
  device  => 'em0',
  address => '10.0.0.1/24',
}
```

It is sometimes desirable to create a VLAN interface without needing to set any
interface addresses on it.  In such a case, simply leave off the address, and
specify the VLAN ID and the device to attach the VLAN to.

```Puppet
bsd::network::interface::vlan { 'vlan100':
  id      => '1',
  device  => 'em0',
  address => '10.0.0.1/24',
}
```

#### carp(4)
```Puppet
bsd::network::interface::carp { "carp0":
  vhid    => '1',
  address => '10.0.0.1/24',
  carpdev => 'em0',
}
```
#### lagg(4) and trunk(4)
```Puppet
bsd::network::interface::trunk { "trunk0":
  interface => ['em0','em1],
  address   => '10.0.0.1/24',
}
```

#### vlan trunks

To configure a set of interfaces as a trunk passing multiple vlans, just leave
the address off of the `trunk(4)` interface and use it as the device for the
`vlan(4)` interface.

```Puppet
bsd::network::interface::trunk { "trunk0":
  interface => ['em0','em1'],
}

bsd::network::interface::carp { "vlan10":
  id      => '10',
  address => '10.0.10.1/24',
  device  => 'trunk0',
}

bsd::network::interface::carp { "vlan11":
  id      => '11',
  address => '10.0.11.1/24',
  device  => 'trunk0',
}
```

#### tun devices

The tun(4) device is supported directly though the `bsd::network::interface`
defined type.

```Puppet
bsd::network::interface { 'tun0':
  values => [
    'up',
    '!/usr/local/bin/openvpn --daemon'
  ]
}
```

#### wireless interfaces

There are many networking options for wifi.  See
[http://www.openbsd.org/faq/faq6.html#Wireless](the openbsd documentation) for
more information.

Use the following to connect to a wireless network using WPA.

```Puppet
bsd::network::interface::wifi { 'athn0':
  network_name => 'myssid',
  network_key  => 'mysecretkey',
}
```

## Contributing

Please help make this module better by sending pull requests and filing issues
for feature requests or bugs.  Please adhere to the style and be mindful of the
  tests.

