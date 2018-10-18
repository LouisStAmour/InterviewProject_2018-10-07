class RotateDataEncryptingKeysWorker
  include Sidekiq::Worker

  def perform(*args)
    Rails.cache.write 'data_encrypting_keys_rotation_job_id', 'active'
    EncryptedString.transaction do
      newkey = DataEncryptingKey.generate!(primary: false)
      # Uses a non-access lock, so the table can still be read, just not written to during this transaction.
      ActiveRecord::Base.connection.execute("LOCK #{EncryptedString.table_name} IN EXCLUSIVE MODE")
      EncryptedString.find_each do |string|
        v = string.value
        string.data_encrypting_key = newkey
        string.value = v
        string.save
      end
      newkey.make_primary!
      # TODO: Delete all DataEncryptingKeys that aren't in use
    end
    Rails.cache.delete 'data_encrypting_keys_rotation_job_id'
  end
end
