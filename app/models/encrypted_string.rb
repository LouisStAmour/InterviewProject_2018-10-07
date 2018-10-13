class EncryptedString < ActiveRecord::Base
  belongs_to :data_encrypting_key

  attr_encrypted :value,
                 mode: :per_attribute_iv,
                 key: :encryption_key,
                 encode: true, encode_iv: true

  validates :token, presence: true, uniqueness: true
  validates :data_encrypting_key, presence: true
  validates :value, presence: true

  before_validation :set_token, :set_data_encrypting_key

  private

  def encryption_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
    data_encrypting_key.key
  end

  def set_token
    begin
      self.token = SecureRandom.hex
    end while EncryptedString.where(token: self.token).present?
  end

  def set_data_encrypting_key
    self.data_encrypting_key ||= DataEncryptingKey.primary
  end
end
