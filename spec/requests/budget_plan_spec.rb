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

RSpec.describe 'GET /budget_plans/:id', type: :request do
  let(:user) {Fabricate(:user)}
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        user
    )
  end
  let(:budget_plan1) {Fabricate(:budget_plan, user: user)}
  let(:budget_plan2) {Fabricate(:budget_plan)}
  let(:url) {'/budget_plans'}

  context 'test budget plan that belongs to user' do
    before do
      get "#{url}/#{budget_plan1.id}", headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('budget_plan')
    end
  end

  context 'test budget plan that not belongs to user' do
    before do
      get "#{url}/#{budget_plan2.id}", headers: auth_headers
    end

    it 'returns 401' do
      expect(response).to have_http_status(401)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('unauthorized')
    end
  end

  context 'test invoice that not exist' do
    before do
      get "#{url}/#{budget_plan2.id + 2}", headers: auth_headers
    end

    it 'returns 404' do
      expect(response).to have_http_status(404)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('not_found')
    end
  end
end

RSpec.describe 'GET /budget_plans/calculate_daily_money', type: :request do
  let(:user) {Fabricate(:user)}
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        user
    )
  end
  let(:url) {'/budget_plans/calculate_daily_money'}

  context 'test calculate_daily_money' do
    before do
      get url, headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end
  end
end
