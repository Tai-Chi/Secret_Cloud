require_relative 'spec_helper'

describe 'Testing file/folder resource routes' do
  before(:each) do
    Tfile.dataset.delete
    Gaccount.dataset.delete
  end
  before(:all) do
    Tfile.dataset.delete
    User.dataset.delete
    User.insert(name: 'Guest', passwd: 'guest')
  end

  describe 'Creating new folders' do
    it 'HAPPY: should create a new folder' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { path: '/home/Guest/' }.to_json
      post '/Guest/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not create existing folders' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { path: '/home/Guest/' }.to_json
      post '/Guest/create/folder', req_body, req_header
      post '/Guest/create/folder', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

end
