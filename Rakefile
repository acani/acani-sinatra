desc "Seed the MongoDB user collection from the stored Flickr photo metadata."
task :seed, :db_name do
  args.with_defaults(:db_name => "acani", :collection => "users")
  FakeProfilePictures.seed_mongodb
end
