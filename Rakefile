begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "mm-active_record_associations"
    gemspec.summary = "Have associations between ActiveRecord objects and MongoMapper documents"
    gemspec.description = ""
    gemspec.email = "ryan@ryanneufeld.ca"
    gemspec.homepage = 'https://github.com/rkneufeld/mm-active_record_associations'
    gemspec.authors = ["Ryan Angilly", "Ryan Neufeld"]

    gemspec.add_development_dependency 'shoulda', '2.11.0'
    gemspec.add_development_dependency 'mocha', '0.9.8'
    gemspec.add_development_dependency 'factory_girl', '1.3.1'
    gemspec.add_development_dependency 'ruby-debug', '0.10.3'
    gemspec.add_development_dependency 'mongo_mapper', '0.8.2'
    gemspec.add_development_dependency 'active_record', '>=2.3.5'

  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
