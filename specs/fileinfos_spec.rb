require_relative './spec_helper'

describe 'Testing file/folder resource routes' do
  
  before do
    Fileinfo.dataset.delete
    Account.dataset.delete
    Gaccount.dataset.delete
    CreateAccount.call(name: 'Dennis Hsieh', passwd: 'Hsieh Dennis')
    CreateAccount.call(name: 'Joey Hong', passwd: 'Hong Joey')
    CreateAccount.call(name: 'Alan Tsai', passwd: 'Tsai Alan')
    CreateAccount.call(name: 'Guest', passwd: 'guest')
  end

  describe 'Creating new folders' do
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

    it 'SAD: should not create existing folders' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/' }.to_json
      post '/create/folder', req_body, req_header
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

  describe 'Creating new files' do
    it 'should successfully create files for all users' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not create a file whose name has been owned by other files' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should check the correctness of the path' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      req_body = { username: 'Guest', path: '/home/Guest/test.txt/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end

  describe 'Renaming new folders' do
    it 'should successfully rename folders for all users' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      # Create files first!
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
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

    it 'SAD: should not rename a file here' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', old_path: '/home/Guest/test.txt', new_name: 'test.txt' }.to_json
      post '/rename/folder', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not rename a non-existing folder' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
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
    it 'should successfully rename files for all users' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      # Create files first!
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Dennis Hsieh', path: '/home/Dennis/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Joey Hong', path: '/home/Joey/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Alan Tsai', path: '/home/Alan/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
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

    it 'SAD: should not rename a folder here' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', old_path: '/home/Guest/', new_name: 'guest' }.to_json
      post '/rename/file', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not rename a non-existing file' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
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
      req_body = { username: 'Guest', path: '/home/Guest/a/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/b/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a' }.to_json
      post '/delete/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/b/c' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/a/b/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not delete a file here' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
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

  describe 'Deleting files' do
    it 'HAPPY: should delete the file' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt' }.to_json
      post '/delete/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 2, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      _(last_response.status).must_equal 200
    end

    it 'SAD: should not delete a folder here' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test' }.to_json
      post '/create/folder', req_body, req_header
      _(last_response.status).must_equal 200
      req_body = { username: 'Guest', path: '/home/Guest/test' , portion: 0}.to_json
      post '/delete/file', req_body, req_header
      _(last_response.status).must_equal 403
    end

    it 'SAD: should not delete a non-existing file' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      req_body = { username: 'Guest', path: '/home/Guest/test.txt', portion: 1, gfid: 1, size: 50 }.to_json
      post '/create/file', req_body, req_header
      req_body = { username: 'Guest', path: '/home/Guest/haha/test.txt' }.to_json
      post '/delete/file', req_body, req_header
      _(last_response.status).must_equal 403
    end
  end
  
end
