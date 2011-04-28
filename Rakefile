desc "Seed the MongoDB user collection from the Flickr photo info."
task :seed, :database, :collection do |t, args|
  args.with_defaults(:database => "acani-staging", :collection => "users")
  require File.expand_path File.join(File.dirname(__FILE__), "seed", "profiles")
  FakeProfilePictures.seed_database(args.database, args.collection)
end
