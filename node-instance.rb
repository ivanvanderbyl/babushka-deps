dep('node provisioned') {
  requires [
    'system',
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'gems.chef'
  ]
}
