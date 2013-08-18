require 'yaml'

class Conf

  @@default_paths = {
    File.expand_path(File.dirname(__FILE__)) + '/../config/cnf.yml'       => nil,
    File.expand_path(File.dirname(__FILE__)) + '/../config/database.yml'  => {root: 'dbs.default'}
  }
  @@fallbacks = {
    'name' => 'database',
    'user' => 'username',
    'pass' => 'password'
  }

  def initialize(new_hash = nil, options = {})
    raise "New hash must be of type Hash" if new_hash && new_hash.class.name != 'Hash'
    @options = {use_fallbacks: true}.merge options
    @loaded_paths = []
    @paths = {}
    @config_hashes = {}
    @compiled_hash = new_hash ? new_hash : {}
  end

  def add_path(new_path)
    if new_path.class.name == 'Hash'
      path_hash = new_path
    elsif new_path.class.name == 'String'
      path_hash = {new_path => nil}
    else
      raise "add_path only accepts stings or hashes"
    end
    @paths = @paths.merge path_hash
    self
  end

  def remove_path(path_to_remove)
    # deletes an element from a hash if its key can be found
    @paths.delete path_to_remove
    self
  end

  def compile_configuration

    # load the defaults if we haven't loaded anything
    use_defaults if @paths.empty?

    # generate output
    out = {}
    @paths.each do |path,options|
      
      # load the file if we haven't already
      load_path path unless @loaded_paths.include? path

      # create a base fragment
      fragment_base = {}

      # create the other nodes
      if options and options.has_key? :root
        fragment = fragment_base
        nodes = options[:root].split '.'
        nodes.each_with_index do |node,i|
          fragment[node] = i == nodes.length-1 ? @config_hashes[path] : {}
          fragment = fragment[node]
        end
      else
        fragment_base = @config_hashes[path]
      end

      # output
      out = out.merge fragment_base

    end
    @compiled_hash = out
    self

  end

  def all_paths_loaded?
    @paths.each do |path,options|
      return false unless @loaded_paths.include? path
    end
    true
  end

  def path_ok?(path)
    path && path.class.name == 'String' and File.exist?(path) and File.file?(path)
  end  

  def check_path!(path)
    raise 'config file "' + path.to_s + '" does not exist' unless path_ok? path
  end

  def check_paths!
    raise 'No config files have not been set' if @paths.empty?
    @paths.each do |path,options|
      check_path! path
    end
    self
  end

  def check_paths
    @paths.each do |path,options|
      @paths.delete path unless path_ok? path
    end
    self
  end  

  def load_paths
    @paths.each do |path,options|
      load_path path
    end
    self
  end

  def load_path(path)
    load_path? path
    self
  end

  def load_path?(path)
    return false unless path_ok? path
    @loaded_paths.push path
    @config_hashes[path] = YAML.load_file path
    self
  end 

  def use_defaults
    @paths = @@default_paths if @paths.empty?
    load_paths
    self
  end

  def get(node = nil, force_type = nil)
    node_val = node ? get_compiled_hash_node_handle(node) : self
    case force_type
      when 'Array'
        return [] unless node_val
        return node_val.class.name == 'Array' ? node_val.clone : node_val.to_a
      when 'Hash'
        return {} unless node_val
        if node_val.class.name == 'Array'
          return array2hash node_val
        elsif node_val.class.name == 'Hash' 
          return node_val.clone
        else
          return node_val.to_hash
        end
      else
        return handle_node_value node_val
    end
  end

  def has_key?(key)
    compiled_hash.has_key? key
  end  

  def get_compiled_hash_node_handle(node = nil)
    if node
      nodes = node.split('.')
      current = compiled_hash
      nodes.each do |node|
        node = @@fallbacks[node] if @options[:use_fallbacks] and !current[node] and @@fallbacks[node]
        current = (current.class.name == 'Hash' or current.class.name == 'Array') ? current[node] : nil
      end
      return current
    else
      return self.compiled_hash
    end
  end  

  def handle_node_value(node)
    return node if node.class.name == 'Conf'
    node = array2hash node if node.class.name == 'Array'
    return node.class.name == 'Hash' ? self.clone.set_compiled_hash(node) : node
  end

  def array2hash(arr)
    return arr if arr.class.name == 'Hash'
    hsh = {}
    arr.each_with_index do |item,i|
      hsh[i] = item
    end
    hsh
  end

  def get_hash(node = nil)
    get(node).compiled_hash
  end

  def to_hash
    compiled_hash.clone
  end

  def to_a
    to_hash.to_a
  end  

  def node_merge!(node1,node2)
    cnf1 = get_compiled_hash_node_handle node1
    cnf2 = get_compiled_hash_node_handle node2
    cnf1.merge!(cnf2) if cnf1 && cnf2
    return self
  end

  def node_merge(node1,node2)
    cnf1 = get_compiled_hash_node_handle node1
    cnf2 = get_compiled_hash_node_handle node2
    return handle_node_value cnf1 if cnf1 && !cnf2
    return handle_node_value cnf1 if cnf2 && !cnf1
    return handle_node_value cnf1.merge(cnf2) if cnf1 && cnf2
  end  

  def merge(node)
    return self unless node
    return handle_node_value compiled_hash.merge(node.to_hash)
  end  

  def each
    compiled_hash.each do |k,v|
      yield k,handle_node_value(v)
    end
  end  

  # Getters and Setters
  # -------------------

  def paths=(new_paths)
    raise "paths must be a hash" unless new_hash.class.name == 'Hash'
    @paths = new_paths
  end  

  def paths
    @paths
  end

  def config_hashes
    @config_hashes
  end  

  def compiled_hash
    compile_configuration if @compiled_hash.empty?
    @compiled_hash
  end

  def compiled_hash=(new_hash)
    raise "compiled hash  must be a hash" unless new_hash.class.name == 'Hash'
    @compiled_hash = new_hash
  end

  def set_compiled_hash(new_hash)
    raise "compiled hash  must be a hash" unless new_hash.class.name == 'Hash'
    @compiled_hash = new_hash
    self
  end  

  # Method Aliases
  # --------------

  def a2h(arr)
    array2hash arr
  end

  def to_hash
    compiled_hash
  end

  def add(new_path)
    add_path new_path
  end

  def remove(path_to_remove)
    remove_path path_to_remove
  end   

end