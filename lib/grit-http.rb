require File.join(File.dirname(__FILE__), 'grit-http/version')
require File.join(File.dirname(__FILE__), 'grit-http/errors')
require File.join(File.dirname(__FILE__), 'grit-http/helpers')
require File.join(File.dirname(__FILE__), 'grit-http/payload')

module GritHttp
  @@config = nil
  @@repositories = {}
  
  # Returns a current configuration
  def self.config
    @@config
  end
  
  # Loads a configuration file
  def self.load_config(path)
    unless File.exists?(path)
      raise RuntimeError, "Configuration file #{path} does not exist!"
    end
    
    @@config = YAML.load_file(path).symbolize_keys
  end
  
  # Initialize application settings
  def self.setup
    check_git_version
    load_repositories(@@config[:repositories])
  end
  
  # Returns true if API key is valid
  def self.valid_api_key?(key)
    @@config[:api_keys].include?(key)
  end
  
  # Add another api key
  def self.add_api_key(key)
    @@config[:api_keys] << key unless valid_api_key?(key)
  end
  
  # Returns all available repository names
  def self.repositories
    @@repositories.keys
  end
  
  # Returns Grit::Repo object created from given name
  def self.repository(name)
    @@repositories[name.to_s]
  end
  
  # Returns true if repository with given name exists
  def self.repository_exists?(name)
    @@repositories.key?(name)
  end
  
  protected
  
  # Check system's git version
  def self.check_git_version
    if `which git`.strip.empty?
      raise RuntimeError, "Git binary was not found. Please install git and try again."
    end
  end
  
  # Loads all repositories
  def self.load_repositories(items=[])
    items.each_pair do |name, path|
      unless repository_exists?(name)
        begin
          @@repositories[name.to_s] = Grit::Repo.new(path)
        rescue Grit::NoSuchPathError
          $stderr.puts "No such path: #{path}. Skipped."
        rescue Grit::InvalidGitRepositoryError
          $stderr.puts "No valid repository at #{path} were found. Skipped."
        end
      else
        $stderr.puts "Repository with name '#{name}' is already defined. Skipped."
      end
    end
  end
end