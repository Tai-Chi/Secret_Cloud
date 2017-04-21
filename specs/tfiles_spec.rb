require_relative './spec_helper'

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
      req_body = { username: 'Guest', path: '/home/Guest/' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not create existing folders' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/' }.to_json
      post '/create/folder', req_body, req_header
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

  describe 'Creating new files' do
    it 'HAPPY: should create a new file' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not create a file whose name has been owned by other files' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should check the correctness of the path' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      req_body = { username: 'Guest', path: '/home/Guest/test.txt/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

  describe 'Renaming new folders' do
    it 'HAPPY: should rename the folder' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', old_path: '/home/Guest', new_name: 'guest' }.to_json
      post '/rename/folder', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not rename a file here' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', old_path: '/home/Guest/test.txt', new_name: 'test.txt' }.to_json
      post '/rename/folder', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not rename a non-existing folder' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      req_body = { username: 'Guest', old_path: '/home/Guest/haha/', new_name: 'HAHA'}.to_json
      post '/rename/folder', req_body, req_header
      _(last_response.status).must_equal 403
      req_body = { username: 'Guest', old_path: '/home/Guest/haha/haha.txt', new_name: 'HAHA.txt' }.to_json
      post '/rename/folder', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

  describe 'Renaming new files' do
    it 'HAPPY: should rename the file' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', old_path: '/home/Guest/test.txt', new_name: 'TEST.txt' }.to_json
      post '/rename/file', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not rename a folder here' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 2 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', old_path: '/home/Guest/', new_name: 'guest' }.to_json
      post '/rename/file', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not rename a non-existing file' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      req_body = { username: 'Guest', old_path: '/home/Guest/haha/test.txt', new_name: 'HAHA.txt'}.to_json
      post '/rename/file', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

  describe 'Deleting folders' do
    it 'HAPPY: should delete the folder' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/' }.to_json
      post '/delete/folder', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'HAPPY: should recurently delete the folder' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/a/b/c' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/b/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a' }.to_json
      post '/delete/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/b/c' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/b/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not delete a file here' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1 }.to_json
      post '/delete/folder', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not delete a non-existing folder' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/haha/' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/GG/' }.to_json
      post '/delete/folder', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

end
