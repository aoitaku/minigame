require 'json'

class Config

  def initialize(config={})
    if config[:last_file]
      config[:last_file] = nil unless File.exist?(config[:last_file])
    end
    @config = config
  end

  def last_file
    @config[:last_file]
  end

  def last_file=(file)
    @config[:last_file] = file
  end

  def save(file)
    File.write(file, JSON.dump(@config))
  end

  def self.load(file)
    if File.exist?(file)
      self.new(JSON.parse(File.read(file), symbolize_names: true))
    else
      self.new
    end
  end

end
