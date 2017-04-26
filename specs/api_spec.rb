require_relative './spec_helper'

describe 'All route tests' do
  # Run before each describe block
  before(:all) do
    Fileinfo.dataset.delete
    Account.dataset.delete
    Gaccount.dataset.delete
    Account.insert(name: 'Dennis Hsieh', passwd: 'Hsieh Dennis')
    Account.insert(name: 'Joey Hong', passwd: 'Hong Joey')
    Account.insert(name: 'Alan Tsai', passwd: 'Tsai Alan')
  end

  describe 'Test /accounts route' do
    it 'should return all accounts of our system' do
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

  describe 'Test /create/folder route' do
    it 'should successfully create folders for all accounts' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Dennis Hsieh', path: '/home' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
    end
  end

  describe 'Test /create/file route' do
    it 'should successfully create files for all users' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
    end
  end

  describe 'Test /rename/folder route' do
    it 'should successfully rename folders for all users' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      # Create files first!
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      # Then rename!
      req_body = { username: 'Dennis Hsieh', old_path: '/home/Dennis', new_name: 'DH' }.to_json
      post '/rename/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', old_path: '/home/Joey', new_name: 'JH' }.to_json
      post '/rename/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', old_path: '/home/Alan', new_name: 'AT' }.to_json
      post '/rename/folder', req_body, req_header
      _(last_response.status).must_equal 200
    end
  end

  describe 'Test /rename/files route' do
    it 'should successfully rename files for all users' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      # Create files first!
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      # Then rename!
      req_body = { username: 'Dennis Hsieh', old_path: '/home/Dennis/test.txt', new_name: 'TEST.txt' }.to_json
      post '/rename/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', old_path: '/home/Joey/test.txt', new_name: 'TEST.txt' }.to_json
      post '/rename/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', old_path: '/home/Alan/test.txt', new_name: 'TEST.txt' }.to_json
      post '/rename/file', req_body, req_header
      _(last_response.status).must_equal 200
    end
  end

end
