dep 'hostname', :for => :linux do
  def hostname
    var(:hostname_str, :default => shell('hostname -f'))
  end
  met? {
    stored_hostname = '/etc/hostname'.p.read
    !stored_hostname.blank? && hostname == stored_hostname
  }
  meet {
    sudo "echo #{var :hostname_str, :default => shell('hostname')} > /etc/hostname"
    sudo "sed -ri 's/^127.0.0.1.*$/127.0.0.1 #{var(:hostname_str)} #{var(:hostname_str).sub(/\..*$/, '')} localhost.localdomain localhost/' /etc/hosts"
    sudo "hostname #{var :hostname_str}"
  }
end
