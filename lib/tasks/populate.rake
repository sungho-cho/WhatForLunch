namespace :db do
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Step 0: initial set-up
    # Drop the old db and recreate from scratch
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    # Invoke rake db:migrate to set up db structure based on latest migrations
    Rake::Task['db:migrate'].invoke

    # Get the faker gem (see docs at http://faker.rubyforge.org/rdoc/)
    require 'faker'

    # -----------------------
    # Step 1: add a default vet and assistant
    user = User.new
    user.first_name = "Jun"
    user.last_name = "Hur"
    user.username = "junhur"
    user.password = "jun_hur"
    user.password_confirmation = "jun_hur"
    user.phone = "412-298-6912"
    user.save!

    user2 = User.new
    user2.first_name = "Sungho"
    user2.last_name = "Cho"
    user2.username = "sunghoch"
    user2.password = "sunghorosho"
    user2.password_confirmation = "sunghorosho"
    user2.phone = "(412) 327-6809"
    user2.save!

    # -----------------------
    # Step 2: add some restaurants to work with (small set for now...)
    restaurants = %w[butcher-and-the-rye-pittsburgh
                     poulet-bleu-pittsburgh
                     täkō-pittsburgh
                     fish-nor-fowl-pittsburgh
                     legume-pittsburgh
                     morcilla-pittsburgh
                     meat-and-potatoes-pittsburgh
                     sausalido-pittsburgh
                     eleven-pittsburgh
                     the-vandal-pittsburgh
                     altius-pittsburgh
                     umami-pittsburgh-2
                     cure-pittsburgh
                     whitfield-pittsburgh
                     the-commoner-pittsburgh-2]
    restaurants.sort.each do |restaurant|
      r = Restaurant.new
      r.business_id = restaurant
      r.save!
    end
    # get an array of animal_ids to use later
    restaurant_ids = Restaurant.all.map{|r| r.id}
    LAT_MIN = 40.427669
    LAT_MAX = 40.483172
    LON_MIN = -80.011570
    LON_MAX = -79.921338
    LAT_DIFF = LAT_MAX-LAT_MIN
    LON_DIFF = LON_MAX-LON_MIN

    50.times do
      order = Order.new
      order2 = Order.new
      order.date = Faker::Date.between(3.months.ago,Date.today)
      order2.date = Faker::Date.between(3.months.ago,Date.today)
      order.user_latitude = (LAT_MIN+LAT_DIFF*Random.rand()).round(6)
      order.user_longitude = (LON_MIN+LON_DIFF*Random.rand()).round(6)
      order2.user_latitude = (LAT_MIN+LAT_DIFF*Random.rand()).round(6)
      order2.user_longitude = (LON_MIN+LON_DIFF*Random.rand()).round(6)
      order.user_id = user.id
      order2.user_id = user2.id
      order.restaurant_id = restaurant_ids[Random.rand(restaurant_ids.length)]
      order2.restaurant_id = restaurant_ids[Random.rand(restaurant_ids.length)]
      order.save!
      order2.save!
    end
  end
end
