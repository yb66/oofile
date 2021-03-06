require 'rubygems'
require 'oofile'
require 'Digest'
require 'yaml'

class HashTraverser < OOFile::Traverser
  attr_reader :entries
  def initialize
    @entries = []
  end

  def traverse_file(file)
     hash = (File.open(file.path) {|ff| Digest::MD5.hexdigest(ff.read())})
     @entries<<{:path=>file.path,:size=>file.size,:hash=>hash}
  end
end


t = HashTraverser.new
OOFile::FsEntry.from('.').traverse(t)

puts t.entries.to_yaml


