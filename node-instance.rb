dep('node provisioned', :hostname_str, :chef_version) {
  requires [
    'system'.with(:hostname_str),
    'ruby',
    'chef install dependencies.managed'.with(chef_version),
    'rubygems',
    'rubygems with no docs',
    'gems.chef'.with(chef_version)
  ]
}
