dep('prince xml installed') {
  requires 'libgif4.managed'

  met? { shell? 'which prince' }
  meet {
    Babushka::Resource.get('http://www.princexml.com/download/prince_8.1-1_ubuntu12.04_amd64.deb') do |download_path|
      shell "cp #{download_path} ./"
      shell "dpkg -i prince_8.1-1_ubuntu12.04_amd64.deb", :sudo => true
    end
  }
}

dep('libgif4.managed') {
  provides []
}
