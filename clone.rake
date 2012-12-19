namespace :db do
  
  class << self
    %w(development test staging production).each do |env|
      define_method("#{env}_db") do 
        Rails.configuration.database_configuration[env]
      end
    end
  end
  
  namespace :clone do
    
    def clone_db(from_db, to_db)
      begin
        start_time = Time.now 
        puts "Cloning Remote DB...."
        system("ssh #{from_db['server_user']}@#{from_db['hostname']} \"mysqldump --lock-tables=false --no-autocommit --quick --skip-add-locks --disable-keys --opt -uroot -p#{from_db['password']} #{from_db['database']} | gzip\" | gzip -d | mysql -uroot -p#{to_db['password']} #{to_db['database']}")
        puts "Import Successful"
        end_time = Time.now 
        puts "===================="
        puts "Job Completed: #{end_time - start_time} Seconds"
      rescue Exception => e
        puts "Import Failed"
      end
    end

    task :staging => :environment do
      clone_db(staging_db, development_db)
    end

    task :production => :environment do
      clone_db(production_db, development_db)
    end
    
    task :staging_to_test => :environment do
      clone_db(staging_db, test_db)
    end

    task :production_to_test => :environment do
      clone_db(production_db, test_db)
    end

  end
  
end
