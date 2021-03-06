#!/usr/bin/env ruby

# Reads bundles to be installed from the .vimrc file then synchronizes
# .vim/bundles by downloading new repositories as needed. It also removes
# bundles that are no longer used.
# This software is covered by the MIT License.

require 'fileutils'
require 'open-uri'

Version = '0.8'


def ensure_dir dir
  Dir.mkdir dir unless test ?d, dir
end


def download_file url, file
  open(url) do |r|
    File.open(file, 'w') do |w|
      w.write(r.read)
    end
  end
end


def run *cmd
  # Runs cmd, returns its stdout, and bails on error.
  # Mostly a backport of Ruby 1.9's IO.popen for 1.8.
  options = { :acceptable_exit_codes => [0], :stderr => nil }
  options.merge!(cmd.pop) if cmd.last.kind_of?(Hash)
  puts "-> #{[cmd].join(" ")}" if $verbose
  outr, outw = IO::pipe
  pid = fork {
    outr.close; STDOUT.reopen outw; outw.close
    STDERR.reopen '/dev/null', 'w' if options[:stderr] == :suppress
    STDERR.reopen STDOUT if options[:stderr] == :merge
    exec *cmd.flatten.map { |c| c.to_s }
  }
  outw.close
  result = outr.read
  outr.close
  Process.waitpid pid
  if options[:acceptable_exit_codes] != :any && !options[:acceptable_exit_codes].include?($?.exitstatus)
    raise "'#{[cmd].join(" ")}' in #{Dir.pwd} exited with code #{$?.exitstatus}"
  end
  puts "RESULT #{$?.exitstatus}: <<#{result}>>" if $verbose && $verbose.to_i >= 2
  result
end


def git *cmd
  if !$verbose && %w{checkout clone fetch pull}.include?(cmd.first.to_s)
    cmd.insert 1, '-q'
  end
  run :git, *cmd
end


def describe_head
  # Don't want to use 'git describe --all' because branch names change too often.
  # This will fail if there's a directory in .vim/bundle that isn't git-revisioned.
  version = git(:describe, '--tags', :acceptable_exit_codes => :any, :stderr => :suppress).chomp
  version = git('rev-parse', 'HEAD', :acceptable_exit_codes => :any, :stderr => :suppress)[0..12] unless version =~ /\S/
  version
end


def current_date
  # Ruby's Time.now.to_s just doesn't produce very good output
  $current_date ||= run(:date).chomp
end


def print_doc_header doc
  doc.printf "%-34s %s\n\n\n", "*bundles* *bundles.txt*", "Installed Bundles"
  doc.puts "Lists the currently installed bundles. Also see the |bundle-log|."
  doc.puts "Last updated by vim-update-bundles on #{current_date}.\n\n"
  doc.printf "  %-32s %-22s %s\n", "PLUGIN", "VERSION", "RELEASE DATE"
  doc.puts "-" * 72
end


def print_doc_entry dir, doc
  version = describe_head
  date = git(:log, '-1', '--pretty=format:%ai').chomp
  doc.printf "  %-32s %-22s %s\n", "|#{dir}|", version, date.split(' ').first
end


def print_log_header log
  log.printf "%-34s %s\n\n\n", "*bundle-log.txt*", "Bundle Install Log"
  log.puts "Logs bundle install activity. Also see the list of installed |bundles|.\n\n"
end


def print_log_entry log, action, dir, rev, notes=""
  message = " %-3s %-26s %-18s %s" % [action, "|#{dir}|", rev, notes]
  log.puts message.sub /\s+$/, ''
end


def log_error log, message
  log.print " #{message}\n\n"  # puts suppresses trailing newline
  STDERR.puts message
end


def ignore_doc_tags
  exclude = File.read ".git/info/exclude"
  if exclude !~ /doc\/tags/
    File.open(".git/info/exclude", "w") { |f|
      f.write exclude.chomp + "\ndoc/tags\n"
    }
  end
end


# Work around Ruby's useless "conflicting chdir during another chdir block" warning
# A better_chdir block can contain a Dir.chdir block,
# but a Dir.chdir block can't contain better_chdir.
def better_chdir dir
  orig = Dir.pwd
  begin
    Dir.chdir dir
    yield
  ensure
    # If the last bundle is removed, git will remove ~/.vim/bundle too.
    ensure_dir orig
    Dir.chdir orig
  end
end


def in_submodule_root config, inpath=nil
  # Submodules often require the CWD to be the Git root. If a path relative to
  # the CWD is passed, the block receives it relative to the root.
  path = File.join Dir.pwd, inpath if inpath
  better_chdir("./" + git('rev-parse', '--show-cdup').chomp) do
    path.sub! /^#{Dir.pwd}\/?/, '' if path
    yield path
  end
end


def clone_bundle config, dir, url, tagstr, log
  unless config[:submodule]
    puts "cloning #{dir} from #{url}#{tagstr}"
    git :clone, url, dir
  else
    puts "adding submodule #{dir} from #{url}#{tagstr}"
    in_submodule_root(config, dir) { |mod| git :submodule, :add, url, mod }
  end
  Dir.chdir(dir) { print_log_entry log, 'Add', dir, describe_head, "#{url}#{tagstr}" }
  $bundles_added += 1
end


def remove_bundle_to config, dir, destination
  puts "Removing #{dir}, find it in #{destination}"
  FileUtils.mv dir, destination
  if config[:submodule]
    in_submodule_root(config, dir) do |mod|
      git :rm, mod
      fn = nil
      ['.gitmodules', '.git/config'].each do |filename|
        begin
          fn = filename
          text = File.read filename
          File.open(filename, 'w+') do |file|
            file.puts text.gsub(/\[submodule "#{mod}"\][^\[]+/m,'')
          end
        rescue Exception => e
          raise "could not delete #{dir} from #{fn}: #{e}"
        end
      end
    end
  end
end


def remove_bundle config, dir, log
  Dir.chdir(dir) { print_log_entry log, 'Del', dir, describe_head }
  trash_dir = "#{config[:vimdir_path]}/Trashed-Bundles"
  ensure_dir trash_dir
  suffixes = [''] + (1..99).map { |i| "-#{"%02d" % i}" }
  suffixes.each do |suffix|
    destination = "#{trash_dir}/#{dir}#{suffix}"
    unless test ?d, destination
      remove_bundle_to config, dir, destination
      $bundles_removed += 1
      return
    end
  end
  raise "unable to remove #{dir}, please delete #{trash_dir}"
end


def reset_bundle config, dir, url, tagstr, log
  remove_bundle config, dir, log
  ensure_dir "#{config[:vimdir_path]}/bundle"
  clone_bundle config, dir, url, tagstr, log
end


def pull_bundle dir, tag, log
  git :fetch, :origin, :stderr => :suppress  # git prints some needless warnings during fetch
  git :checkout, tag || :master

  # if it's a branch, we need to merge in upstream changes
  if system 'git symbolic-ref HEAD -q >/dev/null'
    output = git(:merge, '--ff-only', "origin/#{tag || :master}", :acceptable_exit_codes => :any, :stderr => :merge)
    unless $?.success?
      log_error log, output.gsub(/\s+/, ' ')
      return false   # bundle is not OK and needs to be reset
    end
  end

  return true   # bundle is good, let's continue
end


def install_bundle config, dir, url, tag, doc, log
  tagstr = " at #{tag}" if tag
  previous_version = nil
  only_updating = false

  if url.match /^[A-Za-z0-9-]+\/[A-Za-z0-9._-]+$/  # User/repository.
    url = "https://github.com/#{url}.git"
  end
  if url.match /^[A-Za-z0-9._-]+$/                 # Plain repository.
    url = "https://github.com/vim-scripts/#{url}.git"
  end

  # fetch bundle
  if test ?d, dir
    remote = Dir.chdir(dir)  { git(:config, '--get', 'remote.origin.url').chomp }
    if remote == url
      only_updating = true
      unless config[:no_updates]
        Dir.chdir(dir) { previous_version = describe_head }
        puts "updating #{dir} from #{url}#{tagstr}"
      end
    else
      log_error log, "bundle for #{dir} changed from #{remote} to #{url}"
      reset_bundle config, dir, url, tagstr, log
    end
  else
    clone_bundle config, dir, url, tagstr, log
  end

  # pull bundle
  unless only_updating && config[:no_updates]
    unless Dir.chdir(dir) { pull_bundle dir, tag, log }
      reset_bundle config, dir, url, tagstr, log
    end
    Dir.chdir(dir) do
      ignore_doc_tags
      if previous_version
        new_version = describe_head
        if new_version != previous_version
          print_log_entry log, 'up', dir, "#{new_version}#{tagstr}", "<- #{previous_version}"
          $bundles_updated += 1 if only_updating
        end
      end
    end
  end

  Dir.chdir(dir) { print_doc_entry dir, doc }
  in_submodule_root(config, dir) { |mod| git :add, mod } if config[:submodule]

  only_updating
end


def read_vimrc config
  File.open(config[:vimrc_path]) do |file|
    file.each_line { |line| yield line }
  end
end


class BundleCommandError < RuntimeError
  def exit_code; 47; end
end

def run_bundle_command dir, cmd
  puts "  running: #{cmd}"
  status = Dir.chdir(dir) { system(cmd); $? }
  unless status.success?
    raise BundleCommandError.new("BundleCommand #{cmd} in #{Dir.pwd} failed!")
  end
end


def vim_string str
  if str.slice(0,1) == "'"
    str =~ /^\s*'(.*)'\s*$/
    return $1.gsub "''", "'"
  elsif str.slice(0,1) == '"'
    str =~ /^\s*"(.*)"\s*$/
    return $1    # could do escape substitution here
  else
    return str
  end
end


def update_bundles config, doc, log
  existing_bundles = Dir['*']
  updated_bundles = {}

  # Ignore files in the bundle directory, e.g., READMEs.
  existing_bundles.reject! { |path| FileTest.file? path }

  dir = only_updating = nil
  puts "# reading vimrc" if config[:verbose]
  string_re = %q{'([^']+|'')*'|"[^"]*"}  # captures single and double quoted Vim strings
  read_vimrc(config) do |line|
    if line =~ /^\s*"\s*bundle:\s*(.*)$/i ||
       line =~ /^\s*Bundle\s*(#{string_re})/
      url, tag = vim_string($1).split
      puts "# processing '#{url}' at '#{tag}'" if config[:verbose]
      dir = url.split('/').last.sub(/\.git$/, '')

      # quick sanity check
      raise "duplicate entry for #{url}" if updated_bundles[dir] == url
      raise "urls map to the same bundle: #{updated_bundles[dir]} and #{url}" if updated_bundles[dir]

      only_updating = install_bundle config, dir, url, tag, doc, log
      updated_bundles[dir] = url
      existing_bundles.delete dir
    elsif line =~ /^\s*"\s*bundle[ -]?command:\s*(.*)$/i ||
          line =~ /^\s*BundleCommand\s*(#{string_re})$/
      # Want BundleCommand but BUNDLE COMMAND and Bundle-Command used to be legal too
      raise "BundleCommand must come after Bundle" if dir.nil?
      run_bundle_command dir, vim_string($1) unless only_updating && config[:no_updates]
    elsif line =~ /^\s*"\s*static:\s*(.*)$/i ||
          line =~ /^\s*Bundle!\s*(#{string_re})$/i
      dir = vim_string $1
      puts "  leaving #{dir} alone"
      existing_bundles.delete dir
    end
  end
  existing_bundles.each { |dir| remove_bundle config, dir, log }

  if config[:submodule]
    in_submodule_root(config) do
      puts "  updating submodules"
      git :submodule, :init
      git :submodule, :update
    end
  end
end


def bundleize count
  "#{count} bundle#{count != 1 ? 's' : ''}"
end

def bundle_count_string
  str = []
  str << "#{bundleize $bundles_added} added" if $bundles_added > 0
  str << "#{bundleize $bundles_removed} removed" if $bundles_removed > 0
  str << "#{bundleize $bundles_updated} updated" if $bundles_updated > 0
  return "no updates" if str.empty?

  str[-1] = "and #{str[-1]}" if str.size > 2
  str.join(", ")
end


def update_bundles_and_docs config
  ensure_dir "#{config[:vimdir_path]}/doc"
  bundle_dir = "#{config[:vimdir_path]}/bundle"
  ensure_dir bundle_dir
  $bundles_added = $bundles_removed = $bundles_updated = 0

  File.open("#{config[:vimdir_path]}/doc/bundles.txt", "w") do |doc|
    print_doc_header doc
    logfile = "#{config[:vimdir_path]}/doc/bundle-log.txt"
    log_already_exists = test ?f, logfile
    File.open(logfile, 'a') do |log|
      print_log_header log unless log_already_exists
      log.puts "#{current_date} by vim-update-bundles #{Version}"
      begin
        better_chdir(bundle_dir) { update_bundles config, doc, log }
      rescue Exception => e
        message = e.is_a?(Interrupt) ? "Interrupted" : "Aborted: #{e.message}"
        log_error log, message
        doc.puts message
        STDERR.puts e.backtrace if ENV['TRACE']
        exit e.respond_to?(:exit_code) ? e.exit_code : 1
      end
      log.puts "   " + bundle_count_string
      log.puts
    end
    doc.puts
  end
end


def interpolate options, val, message, i
  raise "Interpolation is now $#{$1} instead of ENV[#{$1}] #{message} #{i}" if val =~ /ENV\[['"]?([^\]]*)['"]?\]/
  STDERR.puts "WARNING: putting quotes in a config item is probably a mistake #{message} #{i}" if val =~ /["']/

  val.gsub(/\$([A-Za-z0-9_]+)/) { options[$1.to_sym] || ENV[$1] || raise("$#{$1} is not defined #{message} #{i}") }
end


def process_options options, args, message
  args.each_with_index do |arg,i|
    arg = arg.gsub /^\s*-?-?|\s*$/, '' # Leading dashes in front of options are optional.
    return if arg == '' || arg =~ /^#/

    k,v = arg.split /\s*=\s*/, 2
    k = options[k.to_sym].to_s while options[k.to_sym].is_a? Symbol # expand 1-letter options, :v -> :verbose
    k.gsub! '-', '_'             # underscorize args, 'no-updates' -> 'no_updates'

    unless options.has_key? k.to_sym
      STDERR.puts "Unknown option: #{k.inspect} #{message} #{i}"
      puts "Usage: #{help}" if args.equal? ARGV
      exit 1
    end

    v = options[k.to_sym].call(v) if options[k.to_sym].is_a? Proc
    options[k.to_sym] = v ? interpolate(options,v,message,i).split("'").join("\\'") : 1 + (options[k.to_sym] || 0)
  end
end


# Returns the first path that exists or the last one if nothing exists.
def choose_path *paths
  paths.find { |p| test ?e, p } || paths[-1]
end


def ensure_vim_environment config
  ensure_dir config[:vimdir_path]
  ensure_dir "#{config[:vimdir_path]}/autoload"

  unless test ?f, "#{config[:vimdir_path]}/autoload/pathogen.vim"
    puts "Downloading Pathogen..."
    download_file config[:pathogen_url], "#{config[:vimdir_path]}/autoload/pathogen.vim"
  end

  unless test(?f, config[:vimrc_path])
    puts "Downloading starter vimrc..."
    download_file config[:starter_url], config[:vimrc_path]
  end
end


def generate_helptags
  puts "updating helptags..."
  # Vim on a Mac often exits with 1, even when doing nothing.
  run :vim, '-e', '-c', 'call pathogen#helptags()', '-c', 'q', :acceptable_exit_codes => [0, 1] unless ENV['TESTING']
end


def locate_vim_files config
  vimdir_guess = choose_path "#{ENV['HOME']}/.dotfiles/vim", "#{ENV['HOME']}/.vim"

  vimrc_guesses = []
  if config[:vimdir_path]
    vimrc_guesses.push "#{config[:vimdir_path]}/.vimrc", "#{config[:vimdir_path]}/vimrc" 
  end
  vimrc_guesses.push "#{ENV['HOME']}/.dotfiles/vimrc", "#{ENV['HOME']}/.vimrc"
  vimrc_guess = choose_path *vimrc_guesses

  config[:vimdir_path] ||= vimdir_guess
  config[:vimrc_path] ||= vimrc_guess
end


def read_configuration config
  conf_file = File.join ENV['HOME'], '.vim-update-bundles.conf'
  process_options config, File.open(conf_file).readlines, "in #{conf_file} line" if test(?f, conf_file)
  process_options config, ARGV, "in command line argument"

  locate_vim_files config

  actual_keys = config.keys.reject { |k| config[k].is_a? Proc or config[k].is_a? Symbol }
  actual_keys.map { |k| k.to_s }.sort.each do |k|
    puts "# option #{k} = #{config[k.to_sym].inspect}"
  end if config[:verbose]
end


def help
<<EOL
vim-update-bundles [options...]
  Updates the installed Vim plugins.
    -n --no-updates: don't update bundles, only add or delete (faster)
    -h -? --help:    print this message
    -v --verbose:    print what's happening (multiple -v for more verbose)
  optional configurations:
    -s --submodule:  store bundles as git submodules
    --vimdir-path:   path to ~/.vim directory
    --vimrc-path:    path to ~/.vimrc directory
EOL
end


config = {
  :verbose       => nil,     # Git commands are quiet by default; set verbose=true to see everything.
  :submodule     => false,   # If true then use Git submodules instead of cloning.
  :no_updates    => false,   # If true then don't update repos, only add or delete.

  :help => lambda { |v| puts help; exit },
  :version => lambda { |v| puts "vim-update-bundles #{Version}"; exit },

  # single-character aliases for command-line options
  :v => :verbose, :s => :submodule, :n => :no_updates,
  :h => :help, :'?' => :help, :V => :version,

  :vimdir_path   => nil,     # Full path to ~/.vim
  :vimrc_path    => nil,     # Full path to ~/.vimrc

  # Used when spinning up a new Vim environment.
  :starter_url   => "https://github.com/bronson/dotfiles/raw/master/.vimrc",
  :pathogen_url  => "https://github.com/tpope/vim-pathogen/raw/master/autoload/pathogen.vim",
}


unless $load_only     # to read the version number
  read_configuration config
  $verbose = config[:verbose]

  ensure_vim_environment config
  update_bundles_and_docs config
  generate_helptags
  puts "done!  Start Vim and type ':help bundles' to see what has been installed."
end
