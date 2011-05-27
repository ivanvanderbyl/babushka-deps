dep 'system' do
  requires 'set.locale', 'hostname', 'tmp cleaning grace period', 'core software'
end

dep 'secured system' do
  requires 'secured ssh logins', 'lax host key checking', 'admins can sudo'
  setup {
    unmeetable "This dep has to be run as root." unless shell('whoami') == 'root'
  }
end

dep 'tmp cleaning grace period', :for => :ubuntu do
  met? { !grep(/^[^#]*TMPTIME=0/, "/etc/default/rcS") }
  meet { change_line "TMPTIME=0", "TMPTIME=30", "/etc/default/rcS" }
end
