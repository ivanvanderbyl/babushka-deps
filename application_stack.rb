dep('application deployable') {
  setup {
    unmeetable! "This dep has to be run as root." unless shell('whoami') == 'root'
  }

  requires [
            'benhoskings:system',
            'benhoskings:ruby.src',
            'benhoskings:user setup for provisioning',
            'testpilot:core dependencies',
            'testpilot:build essential installed',
            'testpilot:postgresql installed']
}

dep('application deployed'){
  setup {
    unmeetable! "This dep cannot be run as root." if shell('whoami') == 'root'
  }

  requires ['ivanvanderbyl:web repo']

}
