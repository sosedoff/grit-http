require 'spec_helper'

describe 'Response' do
  include GritHttp::Helpers
  
  it 'is a proper JSON/UTF8 content' do
    get '/'
    last_response.headers['Content-Type'].should == 'application/json;charset=utf-8'
    proc { JSON.parse(last_response.body) }.should_not raise_error JSON::ParserError
  end
  
  it 'has a proper JSON data' do
    GritHttp.add_api_key('foobar')
    
    get '/', :api_key => 'foobar'
    last_response.status.should == 200
    last_response.body.empty?.should == false
    
    resp = api_response(last_response.body, true)
    resp.should be_an_instance_of(Hash)
    resp.key?('result').should == true
    resp.key?('data').should == true
    resp['result'].should == true
  end
  
  it 'has a valid structure if succeed' do
    resp = api_response(success_response, true)
    resp.should be_an_instance_of(Hash)
    resp.keys.should == %w(result data)
    resp['result'].should == true
    resp['data'].should == {}
  end
  
  it 'has a valid structure if failed' do
    resp = api_response(error_response(0), true)
    resp.should be_an_instance_of(Hash)
    resp.keys.should == %w(result error)
    resp['result'].should == false
    resp['error'].should be_an_instance_of(Hash)
    resp['error'].keys.should == %w(code message)
    resp['error']['code'].should == 0
  end
  
  it 'has a message for each error code' do
    GritHttp::Helpers.constants.each do |c|
      unless c.to_s =~ /^ERROR_MESSAGES/
        val = GritHttp::Helpers.const_get(c)
        GritHttp::Errors.error_message(val).should_not == nil
      end
    end
  end
end
