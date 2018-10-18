class DataEncryptingKeysController < ApplicationController
  def rotate
    jid = Rails.cache.read('data_encrypting_keys_rotation_job_id')
    if jid.nil?
      jid = RotateDataEncryptingKeysWorker.perform
      Rails.cache.write 'data_encrypting_keys_rotation_job_id', jid
    end
  end

  def rotate_status
    jid = Rails.cache.read('data_encrypting_keys_rotation_job_id')
    if jid.nil?
      message = 'No key rotation queued or in progress'
    elsif jid == 'active'
      message = 'Key rotation is in progress'
    else
      message = 'Key rotation has been queued'
    end
    render json: {message: message}, status: :ok
  end
end
