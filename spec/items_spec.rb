require 'spec_helper'

RSpec.describe 'items' do

  before { stub_authentication('username', 'password')}

  let(:todoable) {Todoable::Client.new(user: 'username', password: 'password')}
  let(:list_id) { 'list_id' }

  describe '#create_item' do
    let(:name) { 'My new item' }

    context 'when name is successfully saved' do
      before do
        stub_request(:post, /lists\/list_id\/items/).with(auth_header)
          .with(body: {item: {name: name}})
          .to_return(status: 201, body: {name: name, src: 'url', id: 'item_id'}.to_json)
      end

      it 'returns the saved list' do
        saved_item = todoable.create_item(list_id, name)
        expect(saved_item.name).to eq name
        expect(saved_item.url).to eq 'url'
        expect(saved_item.id).to eq 'item_id'
      end
    end

    context 'when there is a client error' do
      before do
        stub_request(:post, /lists\/list_id\/items/).with(auth_header)
          .to_return(status: 422, body: { name: ['has error', 'has another error']}.to_json)
      end

      it 'warns when repeat list added' do
        expect{todoable.create_item(list_id, name)}.to raise_error 'name has error, name has another error'
      end
    end
  end

end
