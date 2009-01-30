require 'zlib'

# Save any ruby object to disk!
# Objects are stored as gzipped marshal dumps.
#
# Example
#
# # First ruby process
# hash = {1 => "Entry1", 2 => "Entry2"}
# ObjectStash.sotre hash, 'hash.stash'
#
# ...
#
# # Another ruby process - same_hash will be identical to the original hash
# same_hash = ObjectStash.load 'hash.stash'
class ObjectStash

  # Store an object as a gzipped file to disk
  # 
  # Example
  #
  # hash = {1 => "Entry1", 2 => "Entry2"}
  # ObjectStore.store hash, 'hash.stash.gz'
  # ObjectStore.store hash, 'hash.stash', :gzip => false
  def self.store obj, file_name, options={}
    marshal_dump = Marshal.dump(obj)
    file = File.new(file_name,'w')
    file = Zlib::GzipWriter.new(file) unless options[:gzip] == false
    file.write marshal_dump
    file.close
    return obj
  end
  
  # Read a marshal dump from file and load it as an object
  #
  # Example
  #
  # hash = ObjectStore.get 'hash.dump.gz'
  # hash_no_gzip = ObjectStore.get 'hash.dump.gz'
  def self.load file_name
    begin
      file = Zlib::GzipReader.open(file_name)
    rescue Zlib::GzipFile::Error
      file = File.open(file_name, 'r')
    ensure
      obj = Marshal.load file.read
      file.close
      return obj
    end
  end
end
