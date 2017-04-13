require_relative './spec_helper'

describe 'All route tests' do
  before(:all) do
    Tfile.dataset.delete
    User.dataset.delete
    Gaccount.dataset.delete
    User.insert(name: 'Dennis Hsieh', passwd: 'Hsieh Dennis')
    User.insert(name: 'Joey Hong', passwd: 'Hong Joey')
    User.insert(name: 'Alan Tsai', passwd: 'Tsai Alan')
  end

  describe 'Test /users route' do
    it 'should return all users of our system' do
      get '/users'
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

  describe 'Test /:uname/create/folder route' do
    # We should know that a space must be transformed into %20
    # in a URL.
    it 'should successfully create folders for all users' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { path: '/home' }.to_json
      post '/Dennis%20Hsieh/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { path: '/home' }.to_json
      post '/Joey%20Hong/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { path: '/home' }.to_json
      post '/Alan%20Tsai/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { path: '/home/Dennis' }.to_json
      post '/Dennis%20Hsieh/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { path: '/home/Joey' }.to_json
      post '/Joey%20Hong/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { path: '/home/Alan' }.to_json
      post '/Alan%20Tsai/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
    end
  end
end
