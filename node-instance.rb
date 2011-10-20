dep('node provisioned', :hostname, :chef_version) {
  requires [
    'system'.with(hostname),
    'ruby',
    'chef install dependencies.managed'.with(chef_version),
    'rubygems',
    'rubygems with no docs',
    'gems.chef'.with(chef_version)
  ]
}
