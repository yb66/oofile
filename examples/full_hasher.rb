require 'rubygems'
require 'oofile'
require 'Digest'

class HashTraverser < OOFile::Traverser
  def traverse_file(file)
     hash = File.open(file.path) {|ff| Digest::MD5.hexdigest(ff.read())}
     puts "#{file.path} #{hash}"
  end
end

d = OOFile::FsEntry.from('.')
d.traverse(HashTraverser.new)


