dep('node provisioned', :hostname_str, :chef_version) {
  requires [
    'system'.with(:hostname_str),
    'chef install dependencies.managed',
    'ruby19.src',
    'rubygems',
    'rubygems with no docs',
    'zlib headers.managed',
    'gems.chef'.with(chef_version)
  ]
}
