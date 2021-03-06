require 'test_helper'

class EncryptedStringsControllerTest < ActionController::TestCase

  test "POST #create saves new EncryptedString" do
    value_to_encrypt = "to encrypt"
    assert_difference "EncryptedString.count" do
      post :create, params: {encrypted_string: { value: value_to_encrypt }}
    end

    assert_response :success

    json = JSON.parse(response.body)
    assert json["token"]
    encrypted_string = EncryptedString.find_by(token: json["token"])
    assert encrypted_string
    refute_equal encrypted_string.encrypted_value, value_to_encrypt
    assert_equal encrypted_string.value, value_to_encrypt
  end

  test "POST #create returns invalud when value does not exist" do
    assert_no_difference "EncryptedString.count" do
      post :create, params: {encrypted_string: {value: nil}}
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Value can't be blank", json["message"]
  end

  test "get #show returns the decrypted value" do
    @encrypted_string = EncryptedString.create!(value: "decrypted string")

    get :show, params: {token: @encrypted_string.token}

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "decrypted string", json["value"]
  end

  test "round-trip: POST a new token, then GET it" do
    value_to_encrypt = "round-trip encrypt"
    assert_difference "EncryptedString.count" do
      post :create, params: {encrypted_string: { value: value_to_encrypt}}
    end

    assert_response :success

    json = JSON.parse(response.body)
    assert json["token"]

    get :show, params: {token: json["token"]}

    assert_response :success

    json = JSON.parse(response.body)
    assert_equal value_to_encrypt, json["value"]
  end

  test "get #show returns 404 for invalid token" do
    get :show, params: {token: "does not exist"}

    assert_response :not_found
  end

  test "delete #destroy removes the token from the database" do
    @encrypted_string = EncryptedString.create!(value: "value to destroy")


    assert_difference "EncryptedString.count", -1 do
      post :destroy, params: {token: @encrypted_string.token}
    end

    assert_response :success
  end

  test "delete #destroy returns 404 for invalid token" do
    delete :destroy, params: {token: "does not exist"}

    assert_response :not_found
  end
end
