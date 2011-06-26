require 'spec_helper'

describe 'Repository API' do
  before :all do
    GritHttp.add_api_key('foobar')
  end
  
  it 'returns repository information at /repository' do
    # TODO
  end
  
  it 'returns refs at /refs' do
    # TODO
  end
  
  it 'returns heads at /heads' do
    # TODO
  end
  
  it 'returns tags at /tags' do
    # TODO
  end
  
  it 'returns commits at /commits' do
    # TODO
  end
  
  it 'returns a single commit at /commit' do
    # TODO
  end
end
