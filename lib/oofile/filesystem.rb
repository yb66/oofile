#require 'FileUtils'
module OOFile
  
  # Abstract class which is the abstract base class for file system instances
  class FsEntry 
    # This is the canonical path to the file system entry
    attr_reader :path

    def initialize(path)
      @path = File.expand_path(path)
    end
  
    def ==(other)
      self.path==(other.path)
    end

    def extname
      File::extname(@path)
    end

    # the bare filename without the file extension
    def extnless
      b = basename
      b[0,b.size-extname.size]
    end

    def basename
      File::basename(@path)
    end

    def dirname
      File::dirname(@path)
    end
  
    def ctime
      File::ctime(@path)
    end

    def size
      File.size(@path)
    end
  
    # creates a file system entry for a fully qualified pathname
    def self.from(f) 
      return FileEntry.new(f) if File.file?(f) 
      return DirEntry.new(f)  if File.directory?(f) 
      UnknownEntry.new(f)
    end
  
    # creates a file system entry for a filename in the current file system entry object
    def from(fs_entry)
       FsEntry.from(File.join(@path, fs_entry))
    end

    # by default we ignore entries that cannot be handled
    def traverse(entry)
    end

  end

  # I represent a file in the filesystem
  class FileEntry < FsEntry
    
    # I am visitable with a traverser.
    def traverse(traverser)
      traverser.traverse_file(self)
    end
  end

  # I represent filesystem entries that have been detected but aren't supported.
  class UnknownEntry < FsEntry
    def traverse(traverser)
      traverser.traverse_unknown(self)
    end
  end

  # I represent directories in the filesystem.
  class DirEntry < FsEntry	

    # I am visitable with a Traverser. I perform inorder traversal of FsEntries.
    def traverse(traverser)
      traverser.traverse_dir(self)
      Dir.new(@path).each do |stringpath|
        from(stringpath).traverse(traverser) unless stringpath=='.' || stringpath=='..' 
      end
    end

  end

  # Visitor for traversing a filesystem
  class Traverser
    def traverse_dir(dir_entry)
    end
    
    def traverse_file(file_entry)
    end

    def traverse_unknown(unknown_entry)
    end
  end

end
