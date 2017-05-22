require_relative './spec_helper'

describe 'Testing account resource routes' do

  before do
    Fileinfo.dataset.delete
    Account.dataset.delete
    Gaccount.dataset.delete
  end

  describe 'Test /accounts route' do
    it 'should return all accounts of our system' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Dennis Hsieh', email: 'denny0530@gmail.com', passwd: 'dennis' }.to_json
      post '/create/account', req_body, req_header
      req_body = { username: 'Joey Hong', email: 'joypad.y.t.h@gmail.com', passwd: 'joey' }.to_json
      post '/create/account', req_body, req_header
      req_body = { username: 'Alan Tsai', email: 'alan23273850@gmail.com', passwd: 'alan' }.to_json
      post '/create/account', req_body, req_header
      get '/accounts'
      _(last_response.body).must_include 'name'
      _(last_response.body).must_include 'Dennis'
      _(last_response.body).must_include 'Hsieh'
      _(last_response.body).must_include 'Joey'
      _(last_response.body).must_include 'Hong'
      _(last_response.body).must_include 'Alan'
      _(last_response.body).must_include 'Tsai'
      _(last_response.status).must_equal 200
    end
  end

  describe 'Creating new accounts' do
    it 'HAPPY: should create a new account' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', email: 'abc@xyz.com', passwd: 'guest' }.to_json
      post '/create/account', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not create existing accounts' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', email: 'abc@xyz.com', passwd: 'guest' }.to_json
      post '/create/account', req_body, req_header
      post '/create/account', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

  describe 'Deleting accounts' do
    it 'HAPPY: should delete the account' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', email: 'abc@xyz.com', passwd: 'guest' }.to_json
      post '/create/account', req_body, req_header
      post '/delete/account', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not delete a non-existing account' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'WhoAmI', email: 'abc@xyz.com', passwd: 'whoami' }.to_json
      post '/delete/account', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not delete the account if password verification failed' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', email: 'abc@xyz.com', passwd: 'guest' }.to_json
      post '/create/account', req_body, req_header
      req_body = { username: 'Guest', email: 'abc@xyz.com', passwd: 'wrong_password' }.to_json
      post '/delete/account', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

  describe 'Changing passwords' do
    it 'HAPPY: should change the password' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', email: 'abc@xyz.com', passwd: 'guest' }.to_json
      post '/create/account', req_body, req_header
      req_body = { username: 'Guest', old_passwd: 'guest', new_passwd: 'new_guest' }.to_json
      post '/password', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not change the password of a non-existing account' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', old_passwd: 'guest', new_passwd: 'new_guest' }.to_json
      post '/password', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not change the password if password verification failed' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', email: 'abc@xyz.com', passwd: 'guest' }.to_json
      post '/create/account', req_body, req_header
      req_body = { username: 'Guest', old_passwd: 'wrong_password', new_passwd: 'new_guest' }.to_json
      post '/password', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not change the password if the new password is empty' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', email: 'abc@xyz.com', passwd: 'guest' }.to_json
      post '/create/account', req_body, req_header
      req_body = { username: 'Guest', old_passwd: 'guest', new_passwd: '' }.to_json
      post '/password', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end
end