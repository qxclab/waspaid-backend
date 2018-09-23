require 'rails_helper'

RSpec.describe Invoice, type: :model do
  context 'test for saving initial value' do
    it 'create transaction from initial value' do
      post = Fabricate(:invoice)
      expect(post.transactions).not_to be_empty
      expect(post.value).not_to eq(0)
    end

    it 'transactions should be empty if no value was given' do
      post = Fabricate(:invoice, value: nil)
      expect(post.transactions).to be_empty
      expect(post.value).to eq(0)
    end
  end
end
