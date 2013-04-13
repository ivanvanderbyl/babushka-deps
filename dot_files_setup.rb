dep('dot files setup') {
  require 'digest/sha1'

  def files
    Dir.glob(dependency.load_path.parent / "dot_files/dot*.erb")
  end

  def local_to_remote_name(file)
    file = File.basename(file.to_s)
    file.to_s.gsub('dot_', '.').split(/\.erb$/).first
  end

  def dot_file_path
    File.expand_path(ENV['HOME'])
  end

  def current_path
    dot_file_path
  end

  def renderable(path)
    Babushka::Renderable.new(path)
  end

  def rendered_config(local_path)
    renderable(local_path).send(:render_erb, dependency.load_path.parent / local_path, self)
  end

  met?{
    files.all? do |file|
      path = dot_file_path / local_to_remote_name(file)
      File.exists?(path) &&
      Digest::SHA1.hexdigest(rendered_config(file)) == renderable(path).send(:sha_of, path)
    end
  }

  meet {
    files.each do |file|
      shell("cat > '#{dot_file_path / local_to_remote_name(file)}'",
        :input => renderable(dot_file_path / local_to_remote_name(file)).send(:render_erb, dependency.load_path.parent / file, self),
        :sudo => true
      )
      # render_erb file, :to => dot_file_path / local_to_remote_name(file), :credit => false
    end
  }
}