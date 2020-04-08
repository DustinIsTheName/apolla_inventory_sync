task :delete_old_records => :environment do |t, args|
  RemoveOldRecords.remove
end