require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'GET /budget_plans', type: :request do
  let(:user) {Fabricate(:user)}
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        user
    )
  end
  let(:url) {'/budget_plans'}

  context 'test index' do
    before do
      Fabricate(:budget_plan, user: user)
      Fabricate(:budget_plan)
      get url, headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'return only 1 budget plan items' do
      expect {
        JSON.parse(response.body)
      }.to_not raise_error
      result = JSON(response.body)
      expect(result.length).to eq(1)
    end
  end
end
