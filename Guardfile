# directories %w(. config db models specs) \
#.select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}
## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }

#guard :shell do
#  watch(/(.*).txt/) {|m| `tail #{m[0]}` }
#end

#guard :shell do
#  watch /(.*)/ do |m|
#    n m[0], 'Changed'
#    `say -v cello #{m[0]}`
#  end
#end

#guard :shell do
#  watch /.*/ do |m|
#    m[0] + " has changed."
#  end
#end

#guard :shell do
#  watch /.*/ do |m|
#    n m[0], 'File Changed'
#  end
#end


#for comment:
#:66,70s/^/#
#for uncomment:
#:66,70s/^#/

# Example 1: Run a single command whenever a file is added
#notifier = proc do |title, _, changes|
#  Guard::Notifier.notify(changes * ",", title: title )
#end
#
#guard :yield, { run_on_additions: notifier, object: "Add missing specs!" } do
#  watch(/^(.*)\.rb$/) { |m| "spec/#{m}_spec.rb" }
#end

# Example 2: log all kinds of changes
#require 'logger'
#yield_options = {
#  object: ::Logger.new(STDERR), # passed to every other call
#
#  start: proc { |logger| logger.level = Logger::INFO },
#  stop: proc { |logger| logger.info "Guard::Yield - Done!" },
#
#  run_on_modifications: proc { |log, _, files| log.info "!! #{files * ','}" },
#  run_on_additions: proc { |trigger, _, files| trigger.warn "++ #{files * ','}" },
#  run_on_removals: proc { |log, _, files| log.error "xx #{files * ','}" },
#}
#
#guard :yield, yield_options do
#  watch /.*/
#end

additions_pipe = proc do |_, _, changes|
  changes.each do
#    system("ruby car.rb") || throw(:task_has_failed) # IMPORTANT!
    system("echo \"#{changes} added\"") || throw(:task_has_failed) # IMPORTANT!
  end
end

modifications_pipe = proc do |_, _, changes|
  changes.each do
#    system("ls") || throw(:task_has_failed) # IMPORTANT!
    system("echo \"#{changes} modified\"") || throw(:task_has_failed) # IMPORTANT!
  end
end

removals_pipe = proc do |_, _, changes|
  changes.each do
#    system("tree") || throw(:task_has_failed) # IMPORTANT!
    system("echo \"#{changes} removed\"") || throw(:task_has_failed) # IMPORTANT!
  end
end

yield_options = {
  run_on_modifications: modifications_pipe,
  run_on_additions: additions_pipe,
  run_on_removals: removals_pipe
}
  guard :yield, yield_options do
    watch /.*/
  end
