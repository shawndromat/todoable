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

  describe '#finish_item' do

    context 'when the list and item exist' do
      before do
        stub_request(:put, /lists\/list_id\/items\/item_id\/finish/).with(auth_header)
          .to_return(status: 200, body: 'item_id finished')
      end

      it 'returns the finished item' do
        finished_item = todoable.finish_item('list_id', 'item_id')
        expect(finished_item.id).to eq('item_id')
      end
    end

    context 'when a resource is not found' do
      before do
        stub_request(:put, /lists\/list_id\/items\/item_id\/finish/).with(auth_header)
          .to_return(status: 404)
      end
      it 'raises a not found error' do
        expect{todoable.finish_item('list_id', 'item_id')}.to raise_error 'Resource not found'
      end
    end
  end

  describe '#delete_item' do
    context 'when the list and item exists' do
      before do
        stub_request(:delete, /lists\/list_id\/items\/item_id/).with(auth_header)
          .to_return(status: 204)
      end

      it 'returns the item' do
        list = todoable.delete_item('list_id', 'item_id')
        expect(list.id).to eq('item_id')
      end
    end

    context 'when there is no list or item' do
      before do
        stub_request(:delete, /lists\/list_id\/items\/doesnt_exist/).with(auth_header)
          .to_return(status: 404)
      end

      it 'raises a not found error' do
        expect{todoable.delete_item('list_id', 'doesnt_exist')}.to raise_error 'Resource not found'
      end
    end
  end
end
