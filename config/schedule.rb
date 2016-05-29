env :PATH, ENV['PATH']
set :output, "logs/cron_log.log"

every 1.day, :at => '1:00 am' do
  rake "pandora_db:check_vip_expired"
end

every :monday, :at => '0:10 am' do
  rake "pandora_db:update_weekly_stars"
end

every '0 0 1 * *' do #
  rake "pandora_db:update_monthly_stars"
end


every 1.day, :at => '3:00 am' do
  rake "pandora_db:delete_non_activated_designers"
end


every 1.day, :at => '2:00 am' do
  rake "athena_files:delete_temp_images"
end

