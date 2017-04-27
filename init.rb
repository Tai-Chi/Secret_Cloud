folders = 'config,models,controllers,services'
Dir.glob("./{#{folders}}/init.rb").each do |file|
  require file
end