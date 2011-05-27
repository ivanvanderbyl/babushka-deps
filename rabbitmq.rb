dep('rabbitmq-server.managed') {
  requires {
    on :ubuntu, 'updated rabbitmq source'
  }
  
  installs {
    via :apt, 'rabbitmq-server'
  }
  
  provides %w(rabbitmq-server rabbitmqctl)  
  # met? { in_path? 'rabbitmq-server >= 2.4' }
}

dep('updated rabbitmq source') {
  met? { File.exists? "/etc/apt/sources.list.d/rabbitmq.list"}
  meet {
    shell 'echo "deb http://www.rabbitmq.com/debian/ testing main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list'
    shell 'wget -qO - http://www.rabbitmq.com/rabbitmq-signing-key-public.asc | sudo apt-key add -'
    shell 'sudo apt-get update'
  }
}
