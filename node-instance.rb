dep('node provisioned', :hostname_str, :chef_version) {
  requires [
    'system'.with(:hostname_str),
    'chef install dependencies.managed',
    'zlib headers.managed',
    'ruby19.src',
    'rubygems',
    'rubygems with no docs',
    'gems.chef'.with(chef_version)
  ]
}
