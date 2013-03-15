dep('dot files setup') {
  def files
    Dir.glob(dependency.load_path.parent / "dot_files/dot*.erb")
  end

  def local_to_remote_name(file)
    File.basename(file.to_s.gsub(/^dot/, '.').split(/\.erb$/).first)
  end

  def dot_file_path
    File.expand_path(ENV['HOME'])
  end

  met?{
    files.all? do |file|
      Babushka::Renderable.new(dot_file_path / local_to_remote_name(file)).from?(file)
    end
  }

  meet {
    files.each do |file|
      render_erb file, :to => dot_file_path / local_to_remote_name(file)
    end
  }
}