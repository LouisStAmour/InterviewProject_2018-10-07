class UpdateTables < ActiveRecord::Migration[5.2]
  def change
    change_table :encrypted_strings do |t|
      t.remove :encrypted_value_salt
    end

    change_table :data_encrypting_keys do |t|
      t.string :encrypted_key_iv
    end
  end
end
