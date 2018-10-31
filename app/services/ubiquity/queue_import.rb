require 'securerandom'
require 'json'

class QueueImport
  def self.upload(hostname, csv_file, files_directory)
    redis = Redis.current
     msg = { "class" => 'UbiquityCsvImporterJob',
       "queue" => 'ubiquity_csv',
       "args" => ["#{hostname}", "#{csv_file}", "#{files_directory}"],
       'retry' => true,
       'jid' => SecureRandom.hex(12),
       'created_at' => Time.now.to_f,
       'enqueued_at' => Time.now.to_f }
       redis.lpush("queue:ubiquity_csv", JSON.dump(msg) )
  end
end
