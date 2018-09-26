require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'GET /credits', type: :request do
  let(:user) { Fabricate(:user) }
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        user
    )
  end
  let(:url) { '/credits' }

  context 'test index' do
    before do
      Fabricate(:credit, author: user)
      Fabricate(:credit)
      get url, headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'return only 1 invoice' do
      expect {
        JSON.parse(response.body)
      }.to_not raise_error
      result = JSON(response.body)
      expect(result.length).to eq(1)
    end
  end
end

RSpec.describe 'GET /credits/:id', type: :request do
  let(:author) { Fabricate(:user) }
  let(:issued) { Fabricate(:user) }
  let(:author_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        author
    )
  end
  let(:issued_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        { 'Accept' => 'application/json', 'Content-Type' => 'application/json' },
        author
    )
  end
  let(:credit) { Fabricate(:credit, author: author, issued: issued) }
  let(:credit1) { Fabricate(:credit) }
  let(:url) { '/credits' }

  context 'test credit that belongs to user' do
    before do
      get "#{url}/#{credit.id}", headers: author_auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end

    it 'returns parseable json' do
      expect {
        JSON.parse(response.body)
      }.to_not raise_error
    end

    it 'author set to current_user' do
      result = JSON.parse(response.body)
      expect(result['author']['id']).to eq(author.id)
    end
  end

  context 'test credit that not belongs to user' do
    before do
      get "#{url}/#{credit1.id}", headers: author_auth_headers
    end

    it 'returns 401' do
      expect(response).to have_http_status(401)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('unauthorized')
    end
  end

  context 'test credit lifecycle' do
    before do
      get "#{url}/#{credit1.id}", headers: author_auth_headers
    end
  end
end
