dep('node provisioned', :hostname_str, :chef_version) {
  requires [
    # 'system'.with(:hostname_str),
    'hostname'.with(hostname_str),
    'core software'
    # 'chef install dependencies.managed',
    # 'vagrant host dependencies',
    # 'zlib headers.managed',
    # 'ruby19.src',
    # 'rubygems',
    # 'rubygems with no docs',
    # 'gems.chef'.with(chef_version)
  ]
}
