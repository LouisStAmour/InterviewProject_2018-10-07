class DataEncryptingKey < ActiveRecord::Base

  attr_encrypted :key,
                 key: :key_encrypting_key,
                 encode: true, encode_iv: true

  validates :key, presence: true
  validate :only_one_primary_key

  # TODO: Consider moving this constraint into the database -- or another table or KV store.
  # https://dba.stackexchange.com/questions/197562/constraint-one-boolean-row-is-true-all-other-rows-false
  # Alternatively, allow multiple primary keys but make sure the most recent one is chosen.
  # Or when adding new keys, if primary is set to true, lock the table, then invalidate all other rows?
  def only_one_primary_key
    if primary && self.class.where(primary: true).count >= 1
      errors.add(:primary, "must be false if another primary already exists")
    end
  end

  def self.primary
    find_by(primary: true)
  end

  def self.generate!(attrs={})
    create!(attrs.merge(key: AES.key))
  end

  def key_encrypting_key
    ENV['KEY_ENCRYPTING_KEY']
  end

  def make_primary!
    transaction do
      # Uses a non-access lock, so the table can still be read, just not written to during this transaction.
      ActiveRecord::Base.connection.execute("LOCK #{self.class.table_name} IN EXCLUSIVE MODE")
      p = self.class.primary
      p.primary = false
      p.save!
      self.primary = true
      self.save!
    end
  end
end

