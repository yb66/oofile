require 'rubygems'
require 'test/unit'
require 'mocha'
require 'oofile/filesystem'


FS = File::SEPARATOR
TEST_DIRNAME = 'data'
TESTDATA_DIR = ENV['SANDBOX']+FS+'oofile'+FS+'test'+FS+TEST_DIRNAME
TEST_FILENAME = 'testfile.txt'
TEST_FILEPATH = TESTDATA_DIR+FS+TEST_FILENAME

class FsEntryTest < Test::Unit::TestCase
  
def test_instances_and_equality
  a_file       = OOFile::FsEntry.new('/this/that/foo.txt')
  another_file = OOFile::FsEntry.new('/this/that/foo.txt')
  different_file=OOFile::FsEntry.new('/this/that/other.txt')
  
  assert_equal(another_file, a_file)
  assert_equal(a_file, another_file)
  assert_not_equal(a_file, different_file)
  assert_not_equal(another_file, different_file)
end

def test_extname
  assert_equal('.txt', OOFile::FsEntry.new('/this/that/foo.txt').extname)
  assert_equal('', OOFile::FsEntry.new('/this/that/foo.').extname)
  assert_equal('', OOFile::FsEntry.new('/this/that/foo').extname)
  assert_equal('', OOFile::FsEntry.new('/this/that/.foo').extname)  
end

def test_extnless
  assert_equal('foo', OOFile::FsEntry.new('/this/that/foo.txt').extnless)
  assert_equal('foo.',OOFile::FsEntry.new('/this/that/foo.').extnless)
  assert_equal('foo', OOFile::FsEntry.new('/this/that/foo').extnless)
  assert_equal('.foo',OOFile::FsEntry.new('/this/that/.foo').extnless)
end

def test_basename
  assert_equal('foo.txt', OOFile::FsEntry.new('/this/that/foo.txt').basename)
  assert_equal('foo.txt', OOFile::FsEntry.new('/foo.txt').basename)
end

def test_dirname
  assert_equal('/this/that', OOFile::FsEntry.new('/this/that/foo.txt').dirname)
  assert_equal('/this/that', OOFile::FsEntry.new('/this/that/foo/').dirname)
end

def test_ctime
  assert_equal(File::ctime(TEST_FILEPATH), OOFile::FsEntry.new(TEST_FILEPATH).ctime)
  assert OOFile::FsEntry.new(TEST_FILEPATH).ctime.to_i > 0 
end

def test_size
  assert_equal(28, OOFile::FsEntry.new(TEST_FILEPATH).size) 
end

def test_fs_entry_from
  assert_equal OOFile::FileEntry, OOFile::FsEntry.from(TEST_FILEPATH).class
  assert_equal OOFile::DirEntry,  OOFile::FsEntry.from(TESTDATA_DIR).class
  assert_equal OOFile::UnknownEntry, OOFile::FsEntry.from('/dev/null').class
end

def test_instance_fs_entry_from
  instance = OOFile::FsEntry.from(TESTDATA_DIR)
  file_result = instance.from(TEST_FILENAME)
  dir_result  = instance.from('.')

  assert_equal instance.path+FS+TEST_FILENAME, file_result.path
  assert_equal instance.path, dir_result.path
end


end

class FileEntryTest < Test::Unit::TestCase
  
def test_traverse
  traverser = OOFile::Traverser.new
  traverser.expects(:traverse_file).once().with do |file| 
    OOFile::FileEntry==file.class && 'testfile.txt'==file.basename
  end
  traverser.expects(:traverse_dir).never()

  file = OOFile::FsEntry.from(TEST_FILEPATH)
  file.traverse(traverser)
end

end

class DirEntryTest < Test::Unit::TestCase
  
  def test_traverse
    traverser = OOFile::Traverser.new
    traverser.expects(:traverse_file).once().with do |file| 
      OOFile::FileEntry==file.class && 'testfile.txt'==file.basename
    end
    traverser.expects(:traverse_dir).once().with do |dir| 
      OOFile::DirEntry==dir.class && TESTDATA_DIR==dir.path
    end
    traverser.expects(:traverse_unknown).once().with do |unknown|
      OOFile::UnknownEntry==unknown.class && 'pipeentry'==unknown.basename
    end

    file = OOFile::FsEntry.from(TESTDATA_DIR)
    file.traverse(traverser)
  end

end

class UnknownEntryTest < Test::Unit::TestCase
  def test_traverse
    traverser = OOFile::Traverser.new
    traverser.expects(:traverse_unknown).once().with do |unknown|
      OOFile::UnknownEntry==unknown.class && 'pipeentry'==unknown.basename
    end
    file = OOFile::FsEntry.from(File.join(TESTDATA_DIR,'pipeentry'))
    file.traverse(traverser)
  end
  
  def test_traverse_on_nonexistent_handled_as_unknown
    traverser= OOFile::Traverser.new
    traverser.expects(:traverse_file).never()
    traverser.expects(:traverse_dir).never()
    traverser.expects(:traverse_unknown).once().with do |unknown|
      OOFile::UnknownEntry==unknown.class && 'nonexistentfile'==unknown.basename
    end

    file = OOFile::FsEntry.from(File.join(TESTDATA_DIR,'nonexistentfile'))
   
    assert_equal file.class, OOFile::UnknownEntry
    file.traverse(traverser)
  end

end
