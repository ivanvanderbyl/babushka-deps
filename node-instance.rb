dep('node provisioned', :hostname_str, :chef_version) {
  requires [
    'system'.with(:hostname_str),
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'gems.chef'.with(chef_version)
  ]
}
