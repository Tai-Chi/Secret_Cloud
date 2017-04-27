require_relative './spec_helper'

describe 'Test / route' do
  it 'should return our project title' do
    get '/'
    _(last_response.body).must_include 'File System Synchronization web API'
    _(last_response.status).must_equal 200
  end
end
