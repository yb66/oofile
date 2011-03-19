require 'test/unit'
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

File.open 'VERSION' do |file|
  RELEASE_VERSION = file.readline
end

RDOC_OPTS = ['--quiet', '--title', "oofile Reference #{RELEASE_VERSION}", '--main', 'README.rdoc', '--inline-source']

# create a non-supported filesystem entry for test data if necessary
pipeentry_pathname=ENV['SANDBOX']+'/oofile/test/data/pipeentry'
if !File.exists? pipeentry_pathname
`mkfifo #{pipeentry_pathname}`
end

Rake::TestTask.new(:default) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  #t.verbose = true
end

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.main = "README.rdoc"
    rdoc.rdoc_files.add ['README.rdoc', 'CHANGELOG.rdoc', 'COPYING', 'TODO.rdoc', 'lib/**/*.rb', 'doc/demo.rdoc']
end

def ftpsession
  Net::FTP.open(@ftphost) do |ftp|
    ftp.passive = true
    ftp.debug_mode = true
    ftp.login @ftpusername, @ftppassword
    yield ftp
  end
end

def uploader ftp
  proc do |l|
    raise "%s not found " % l unless File.exist? l
    ftp.putbinaryfile l, l
  end
end

def initialiseRdocFTPCredentials
  require 'net/ftp'
  require 'yaml'
  config = YAML::load(File.open(File.expand_path('~/.greenbarftp')))
  @ftpusername =config['username']
  @ftppassword =config['password']
  @ftphost     =config['host']
  @ftpsitepath =config['sitepath'] 
end

desc "upload the rdoc by ftp" 
task :upload_rdoc => :rerdoc do
  initialiseRdocFTPCredentials
  Dir.chdir ENV['SANDBOX']+'/oofile/doc/rdoc' do
      ftpsession do |ftp|
      uploader = uploader ftp
      ftp.chdir @ftpsitepath
      ftp.chdir 'software/oofile/rdoc'
      Dir['**/*.*'].each &uploader
  end
end

end


SPEC = Gem::Specification.new do |s| 
	s.name = "oofile" 
	s.description = "Object-oriented access to the filesystem."
	s.version = RELEASE_VERSION
	s.author = "Dafydd Rees" 
	s.email = "os@greenbarsoft.co.uk" 
	s.homepage = "http://www.greenbarsoft.co.uk/software/oofile" 
	s.platform = Gem::Platform::RUBY 
	s.summary = "Object-oriented, traversable file system representation." 
	candidates = Dir.glob("{doc,lib,test,testfiles}/**/*") 
	s.files = candidates.delete_if do |item| 
	  item.include?("CVS") ||
          item.include?("rdoc") ||
          item.include?("test/data/pipeentry") 
	end 
	s.require_path = "lib" 
	s.test_files =  Dir['./test/**/*.rb']
	s.add_development_dependency('mocha', '>= 0.9.8')
	s.add_development_dependency('rcov', '>= 0.9.6')
	s.has_rdoc = true 
	s.extra_rdoc_files = ["CHANGELOG.rdoc","COPYING","README.rdoc", "doc/demo.rdoc","TODO.rdoc"] 
end

Rake::GemPackageTask.new(SPEC) do |pkg|
  pkg.need_tar = true
end

desc "create interactive demo script" 
task :create_demo do
        directory_prefix = ENV['SANDBOX']+'/oofile/doc/'
        File.open(directory_prefix+'demo.rdoc','w') do |f|
          f.puts "== Sample output "
          f.puts
          f.puts
          result = `irb -I#{ENV['SANDBOX']}/oofile/lib  #{directory_prefix}demo.script`
          result.gsub! /^/,"    "
          f.puts result
          f.puts "\n\n oofile #{RELEASE_VERSION}\n"
        end
end

task :rdoc => :create_demo

require 'rcov/rcovtask'
 Rcov::RcovTask.new do |t|
   t.test_files = FileList['test/*_test.rb']
   t.rcov_opts = ['--exclude', '/rubygems,/gems/']  
   # t.verbose = true     # uncomment to see the executed command
 end
