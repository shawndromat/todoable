require 'spec_helper'

RSpec.describe 'lists' do

  before { stub_authentication('username', 'password')}

  let(:todoable) {Todoable::Client.new(user: 'username', password: 'password')}

  describe '#create_list' do
    let(:name) { 'My new list' }

    context 'when name is successfully saved' do
      before do
        stub_request(:post, /lists/).with(auth_header)
          .with(body: {list: {name: /.*/}})
          .to_return(status: 201, body: {list: {name: name, src: 'url', id: 'list_id'}}.to_json)
      end

      it 'returns the saved list' do
        saved_list = todoable.create_list(name)
        expect(saved_list.name).to eq name
        expect(saved_list.url).to eq 'url'
        expect(saved_list.id).to eq 'list_id'
      end
    end

    context 'when there is a client error' do
      before do
        stub_request(:post, /lists/).with(auth_header)
          .to_return(status: 422, body: { name: ['has error', 'has another error']}.to_json)
      end

      it 'warns when repeat list added' do
        expect{todoable.create_list(name)}.to raise_error 'name has error, name has another error'
      end
    end
  end

  describe '#lists' do
    before do
      stub_request(:get, /lists/).with(auth_header)
        .to_return(status: 201, body: lists_body.to_json)
    end

    context 'when there are lists' do
      let(:lists_body) do
        {
          lists: [
            { name: 'cool list', src: 'todoable.tech/api/1', id: '1'},
            { name: 'rad list', src: 'todoable.tech/api/2', id: '2'},
          ]
        }
      end

      it 'returns collection of list objects' do
        all_lists = todoable.lists
        expect(all_lists.size).to eq(2)
        expect(all_lists.first.name).to eq('cool list')
        expect(all_lists.first.url).to eq('todoable.tech/api/1')
        expect(all_lists.first.id).to eq('1')
      end
    end

    context 'when there are no lists' do
      let(:lists_body) { { lists: [] } }

      it 'returns an empty array' do
        expect(todoable.lists).to eq([])
      end
    end
  end

  describe '#list' do
    context 'when the list exists' do
      before do
        stub_request(:get, /lists/).with(auth_header)
          .to_return(status: 201, body: list_body)
      end

      let(:list_body) do
        File.new(File.expand_path('../fixtures/list.json', __FILE__))
      end

      it 'returns the list and accompanying items' do
        list = todoable.list('12345')
        expect(list.id).to eq('12345')
        expect(list.name).to eq('Urgent Things')

        expect(list.items.size).to eq(2)
        expect(list.items.first.name).to eq('Feed the cat')
        expect(list.items.first.finished_at).to eq(nil)
        expect(list.items.first.url).to eq('item1_url')
        expect(list.items.first.id).to eq('item1')
      end
    end

    context 'when there is no list for the id' do
      before do
        stub_request(:get, /lists/).with(auth_header)
          .to_return(status: 404)
      end

      it 'raises an error' do
        expect{todoable.list('doesnt_exist')}.to raise_error 'Resource not found'
      end
    end
  end

  describe '#update_list' do
    let(:id) {'12345'}
    let(:name) { 'Updated list name' }

    context 'when the list exists' do
      before do
        stub_request(:patch, /lists\/12345/).with(auth_header)
          .with(body: {list: {name: name}})
          .to_return(status: 201, body: {list: {name: name, src: 'url', id: id}}.to_json)
      end

      it 'returns the updated list' do
        updated_list = todoable.update_list(id, name)
        expect(updated_list.name).to eq('Updated list name')
        expect(updated_list.id).to eq('12345')
      end
    end

    context 'when there is a client error' do
      before do
        stub_request(:patch, /lists\/12345/).with(auth_header)
          .with(body: {list: {name: name}})
          .to_return(status: 422, body: { name: ['has error', 'has another error']}.to_json)
      end

      it 'raises an error' do
        expect{todoable.update_list(id, name)}.to raise_error 'name has error, name has another error'
      end
    end

    context 'when the list does not exist' do
      before do
        stub_request(:patch, /lists\/12345/).with(auth_header)
          .with(body: {list: {name: name}})
          .to_return(status: 404)
      end
      it 'raises a not found error' do
        expect{todoable.update_list(id, name)}.to raise_error 'Resource not found'
      end
    end
  end

  describe '#delete_list' do
    context 'when the list exists' do
      before do
        stub_request(:delete, /lists\/12345/).with(auth_header)
          .to_return(status: 201, body: list_body)
      end

      let(:list_body) do
        File.new(File.expand_path('../fixtures/list.json', __FILE__))
      end

      it 'returns the list and accompanying items' do
        list = todoable.delete_list('12345')
        expect(list.id).to eq('12345')
      end
    end

    context 'when there is no list for the id' do
      before do
        stub_request(:delete, /lists\/doesnt_exist/).with(auth_header)
          .to_return(status: 404)
      end

      it 'raises an error' do
        expect{todoable.delete_list('doesnt_exist')}.to raise_error 'Resource not found'
      end
    end
  end
end
