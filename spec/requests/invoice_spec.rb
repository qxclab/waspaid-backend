require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'GET /invoices', type: :request do
  let(:user) { Fabricate(:user) }
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        user
    )
  end
  let(:url) { '/invoices' }

  context 'test index' do
    before do
      Fabricate(:invoice, user: user)
      Fabricate(:invoice)
      get url, headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'return only 2 invoice' do
      expect {
        JSON.parse(response.body)
      }.to_not raise_error
      result = JSON(response.body)
      expect(result.length).to eq(2)
    end
  end
end

RSpec.describe 'GET /invoices/:id', type: :request do
  let(:user) { Fabricate(:user) }
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        user
    )
  end
  let(:invoice1) { Fabricate(:invoice, user: user) }
  let(:invoice2) { Fabricate(:invoice) }
  let(:url) { '/invoices' }

  context 'test invoice that belongs to user' do
    before do
      get "#{url}/#{invoice1.id}", headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('invoice')
    end
  end

  context 'test invoice that not belongs to user' do
    before do
      get "#{url}/#{invoice2.id}", headers: auth_headers
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
      get "#{url}/#{invoice2.id + 2}", headers: auth_headers
    end

    it 'returns 404' do
      expect(response).to have_http_status(404)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('not_found')
    end
  end
end

RSpec.describe 'POST /invoices', type: :request do
  let(:user) { Fabricate(:user) }
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        user
    )
  end
  let(:invoice) { Fabricate(:invoice) }
  let(:url) { '/invoices' }
  let(:params) do
    {
        invoice: {
            name: invoice.name,
            description: invoice.description,
            value: invoice.value
        }
    }.to_json
  end

  context 'test invoice' do
    before do
      post url, params: params, headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'belongs to user' do
      expect(Invoice.last.user.id).to eq(user.id)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('invoice')
    end
  end
end

RSpec.describe 'PUT /invoices/:id', type: :request do
  let(:user) { Fabricate(:user) }
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        user
    )
  end
  let(:invoice) { Fabricate(:invoice, user: user) }
  let(:url) { '/invoices' }
  let(:params) do
    {
        invoice: {
            value: Faker::Number.decimal(2)
        }
    }.to_json
  end

  context 'test invoice' do
    before do
      put "#{url}/#{invoice.id}", params: params, headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'still belongs to user' do
      expect(Invoice.last.user.id).to eq(user.id)
    end

    it 'value not changed' do
      expect {
        JSON.parse(response.body)
      }.to_not raise_error
      result = JSON(response.body)
      expect(result['value']).to eq(invoice.value.to_s)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('invoice')
    end
  end
end

RSpec.describe 'DELETE /invoices/:id', type: :request do
  let(:user) { Fabricate(:user) }
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        user
    )
  end
  let(:invoice1) { Fabricate(:invoice, user: user) }
  let(:invoice2) { Fabricate(:invoice) }
  let(:url) { '/invoices' }

  context 'test invoice that belongs to user' do
    before do
      delete "#{url}/#{invoice1.id}", headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('success')
    end
  end

  context 'ensure that user has at least one invoice' do
    before do
      delete "#{url}/#{user.invoices.last.id}", headers: auth_headers
    end

    it 'returns 400' do
      expect(response).to have_http_status(400)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('bad_request')
    end
  end

  context 'test invoice that not belongs to user' do
    before do
      delete "#{url}/#{invoice2.id}", headers: auth_headers
    end

    it 'returns 401' do
      expect(response).to have_http_status(401)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('unauthorized')
    end
  end
end
