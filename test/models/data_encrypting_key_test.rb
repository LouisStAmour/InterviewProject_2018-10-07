require 'test_helper'

class DataEncryptingKeyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  # Requirement: Generate a new Data Encrypting Key
  test ".generate!" do
    assert_difference "DataEncryptingKey.count" do
      key = DataEncryptingKey.generate!
      assert key
    end
  end

  test "cannot generate two primary keys" do
    key = DataEncryptingKey.generate!(primary: true)
    exception = assert_raises ActiveRecord::RecordInvalid do
      key2 = DataEncryptingKey.generate!(primary: true)
    end
    assert_equal('Validation failed: Primary must be false if another primary already exists', exception.message)
  end

  # Requirement: Set the new key to be the primary one (primary: true), while making any old primary key(s) non-primary (primary: false)
  test "can set another key as primary" do
    nonprimary = DataEncryptingKey.generate!(primary: false)
    primary = DataEncryptingKey.generate!(primary: true)
    assert_equal DataEncryptingKey.primary, primary
    nonprimary.make_primary!
    nonprimary.reload
    primary.reload
    assert_equal false, primary.primary, "previous primary key should have primary = false"
    assert_equal true, nonprimary.primary, "new primary key should have primary = true"
  end

  # Requirement: Transactionally, write-locked? re-encrypt all strings with a key and delete other keys
  # Alternatively, set the new key to default, then re-encrypt all other strings with the new key
  # Another thought -- every time generate! is called, we could re-encrypt existing keys?
end
