SEED_DIR = File.expand_path(File.join(File.dirname(__FILE__), "seed"))
require File.join(SEED_DIR, "database")

desc "Seed the MongoDB users & interests collections."
task :seed => ["db:drop", "db:seed:users", "db:seed:interests"]

namespace "db" do
  desc "Drop (remove) the MongoDB database."
  task :drop, :database do |t, args|
    args.with_defaults(:database => "acani-staging")
    Acani.drop_database(args.database)
  end
  
  namespace "seed" do
    desc "Seed the MongoDB interests collection from interests.yml."
    task :interests, :database, :collection do |t, args|
      args.with_defaults(:database => "acani-staging", :collection => "i")
      Acani.seed_interests(args.database, args.collection)
    end

    desc "Seed the MongoDB user collection from the Flickr photo info."
    task :users, :database, :collection do |t, args|
      args.with_defaults(:database => "acani-staging", :collection => "u")
      FakeProfilePictures.seed_users(args.database, args.collection)
    end
  end
end