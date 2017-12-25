require 'spec_helper'

RSpec.describe 'lists' do

  before { stub_authentication('username', 'password')}

  let(:todoable) {Todoable::Client.new(user: 'username', password: 'password')}

  describe '#create_list' do
    let(:name) { 'My new list' }

    context 'when name is successfully saved' do
      before do
        stub_request(:post, /lists/).with(auth_header)
          .to_return(status: 201, body: '{}')
      end

      it 'returns the saved list' do
        saved_list = todoable.create_list(name)
        expect(saved_list.name).to eq name
      end
    end

    context 'when there is an error' do
      before do
        stub_request(:post, /lists/).with(auth_header)
          .to_return(status: 422, body: { name: ['has error', 'has another error']}.to_json)
      end

      it 'warns when repeat list added' do
        expect{
          todoable.create_list(name)
          todoable.create_list(name)
        }.to raise_error 'name has error, name has another error'
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
    before do
      stub_request(:get, /lists/).with(auth_header)
        .to_return(status: 201, body: list_body)
    end

    context 'when the list exists' do
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
      let(:list_body) do
        File.new(File.expand_path('../fixtures/list.json', __FILE__))
      end
    end
  end
end
