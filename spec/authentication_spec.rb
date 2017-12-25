require 'spec_helper'

RSpec.describe 'authentication' do
  before do
    stub_authentication('username', 'password').times(1).then
      .to_return(status: 200, body: {token: 'new_token'}.to_json)

    stub_request(:get, /lists/)
      .with(headers: {'Authorization' => 'Token token="my_token"'})
      .to_return(lists_response).times(1).then
      .to_return(status: 401)
  end

  context 'when user and password provided' do
    let(:todoable) {Todoable::Client.new(user: 'username', password: 'password')}

    it 'allows user to make calls' do
      expect {todoable.lists}.not_to raise_error
    end

    context 'when the token expires' do
      before do
        stub_request(:get, /lists/)
          .with(headers: {'Authorization' => 'Token token="new_token"'})
          .to_return(lists_response)
      end

      it 'refreshes the token' do
        expect do
          todoable.lists
          todoable.lists
        end.not_to raise_error
      end
    end
  end

  context 'when blank user and password provided' do
    let(:todoable) {Todoable::Client.new(user: '', password: '')}

    it 'raises an error' do
      expect {todoable.lists}.to raise_error('Bad authentication data')
    end
  end

  def lists_response
    {status: 200, body: {lists: []}.to_json}
  end
end
