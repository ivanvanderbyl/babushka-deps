dep('prince xml installed') {
  met? { shell? 'which prince' }
  meet {
    Babushka::Resource.get('http://www.princexml.com/download/prince_7.2-4ubuntu10.04_amd64.deb') do |download_path|
      shell "cp #{download_path} ./"
      shell "dpkg -i prince_7.2-4ubuntu10.04_amd64.deb"
    end
  }
}
