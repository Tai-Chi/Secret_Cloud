require 'json'
require 'base64'
require 'rbnacl/libsodium'

# Holds a full configuration document information
class Configuration
  STORE_DIR = 'db/'.freeze

  attr_accessor :id, :name, :passwd, :priv_key, :pub_key

  def initialize(new_configuration)
    @id = new_configuration['id'] || new_id
    @name = new_configuration['name']
    @passwd = new_configuration['passwd']
    @priv_key = new_configuration['priv_key']
    @pub_key = new_configuration['pub_key']
  end

  def new_id
    Base64.urlsafe_encode64(RbNaCl::Hash.sha256(Time.now.to_s))[0..9]
  end

  def to_json(options = {})
    JSON({ id: @id,
           name: @name,
           passwd: @passwd,
           priv_key: @priv_key,
           pub_key: @pub_key },
         options)
  end

  def save
    File.open(STORE_DIR + @id + '.txt', 'w') do |file|
      file.write(to_json)
    end
    true
  rescue
    false
  end

  def self.find(find_id)
    config_file = File.read(STORE_DIR + find_id + '.txt')
    Configuration.new JSON.parse(config_file)
  end

  def self.all
    Dir.glob(STORE_DIR + '*.txt').map do |filename|
      filename.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
    end
  end

  def self.setup
    Dir.mkdir(Configuration::STORE_DIR) unless Dir.exist? STORE_DIR
  end
end
