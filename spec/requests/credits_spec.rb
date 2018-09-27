require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'GET /credits', type: :request do
  let(:user) {Fabricate(:user)}
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        user
    )
  end
  let(:url) {'/credits'}

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
  let(:author) {Fabricate(:user)}
  let(:issued) {Fabricate(:user)}
  let(:author_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        author
    )
  end
  let(:issued_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        author
    )
  end
  let(:credit) {Fabricate(:credit, author: author, issued: issued)}
  let(:credit1) {Fabricate(:credit)}
  let(:url) {'/credits'}

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
end


RSpec.describe 'POST /credits', type: :request do
  let(:user) {Fabricate(:user)}
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        user
    )
  end
  let(:credit) {Fabricate(:credit)}
  let(:url) {'/credits'}

  context 'test credit' do
    before do
      params = {
          credit: {
              description: credit.description,
              value: credit.value,
              issued_id: credit.issued.id,
          }
      }.to_json
      post url, params: params, headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'belongs to user' do
      expect(Credit.last.author.id).to eq(user.id)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end
  end

  context 'test credit if issued to user himself' do
    before do
      params = {
          credit: {
              description: credit.description,
              value: credit.value,
              issued_id: user.id,
          }
      }.to_json
      post url, params: params, headers: auth_headers
    end

    it 'returns 400' do
      expect(response).to have_http_status(400)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('bad_request')
    end
  end
end


RSpec.describe 'POST /credits/:id/:lifecycle_method', type: :request do
  let(:author) {Fabricate(:user)}
  let(:issued) {Fabricate(:user)}
  let(:author_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        author
    )
  end
  let(:issued_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        issued
    )
  end
  let(:url) {'/credits'}

  context 'test confirm_credit' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end
  end

  context 'test confirm_money_transfer should throw 400 when from issued' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
    end

    it 'returns 400' do
      expect(response).to have_http_status(400)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('bad_request')
    end
  end

  context 'test confirm_money_transfer' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end

    it 'state equal money_transferred' do
      result = JSON.parse(response.body)
      expect(result['state']).to eq('money_transferred')
    end
  end

  context 'test pay' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
      post "#{url}/#{credit.id}/pay", headers: issued_auth_headers, params: {'credit': {'value': credit.initial_value}}.to_json
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end

    it 'pending_money to be > 0' do
      result = JSON.parse(response.body)
      expect(result['pending_money'].to_i).to be > 0
    end

    it 'state equal pending_payment' do
      result = JSON.parse(response.body)
      expect(result['state']).to eq('pending_payment')
    end
  end

  context 'test confirm_payment when paid_partly' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
      post "#{url}/#{credit.id}/pay", headers: issued_auth_headers, params: {'credit': {'value': credit.initial_value.to_f}}.to_json
      post "#{url}/#{credit.id}/confirm_payment", headers: author_auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end

    it 'pending_money equal 0' do
      result = JSON.parse(response.body)
      expect(result['pending_money'].to_i).to eq(0)
    end

    it 'value greater than o' do
      result = JSON.parse(response.body)
      expect(result['value'].to_i).to be > 0
    end

    it 'state equal paid_partly' do
      result = JSON.parse(response.body)
      expect(result['state']).to eq('paid_partly')
    end
  end

  context 'test confirm_payment when paid full amount' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
      post "#{url}/#{credit.id}/pay", headers: issued_auth_headers, params: {'credit': {'value': credit.value.to_f + credit.fee.to_f}}.to_json
      post "#{url}/#{credit.id}/confirm_payment", headers: author_auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end

    it 'pending_money equal 0' do
      result = JSON.parse(response.body)
      expect(result['pending_money'].to_i).to eq(0)
    end

    it 'value equal 0' do
      result = JSON.parse(response.body)
      expect(result['value'].to_i).to eq(0)
    end

    it 'state equal paid' do
      result = JSON.parse(response.body)
      expect(result['state']).to eq('paid')
    end
  end

  context 'test confirm_payment when paid full amount when time passed' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued, expired_at: DateTime.yesterday)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
      post "#{url}/#{credit.id}/pay", headers: issued_auth_headers, params: {'credit': {'value': credit.value.to_f + credit.fee.to_f}}.to_json
      post "#{url}/#{credit.id}/confirm_payment", headers: author_auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end

    it 'pending_money equal 0' do
      result = JSON.parse(response.body)
      expect(result['pending_money'].to_i).to eq(0)
    end

    it 'value equal initial 0' do
      result = JSON.parse(response.body)
      expect(result['value'].to_i).to eq(0)
    end

    it 'state equal late_paid' do
      result = JSON.parse(response.body)
      expect(result['state']).to eq('late_paid')
    end
  end

  context 'test reject_payment' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
      post "#{url}/#{credit.id}/pay", headers: issued_auth_headers, params: {'credit': {'value': credit.value.to_f}}.to_json
      post "#{url}/#{credit.id}/reject_payment", headers: author_auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end

    it 'pending_money equal 0' do
      result = JSON.parse(response.body)
      expect(result['pending_money'].to_i).to eq(0)
    end

    it 'state equal pay_failed' do
      result = JSON.parse(response.body)
      expect(result['state']).to eq('pay_failed')
    end
  end

  context 'test forgive' do
    before do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
      post "#{url}/#{credit.id}/forgive", headers: author_auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'match the schema' do
      expect(response).to match_response_schema('credit')
    end

    it 'state equal forgiven' do
      result = JSON.parse(response.body)
      expect(result['state']).to eq('forgiven')
    end
  end

  context 'test for errors' do

    it 'in confirm_credit' do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      post "#{url}/#{credit.id}/confirm_credit", headers: issued_auth_headers
      expect(response).to have_http_status(400)
    end

    it 'in confirm_money_transfer' do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_money_transfer", headers: author_auth_headers
      expect(response).to have_http_status(400)
    end

    it 'in pay' do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/pay", headers: issued_auth_headers
      expect(response).to have_http_status(400)
    end

    it 'in confirm_payment' do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/confirm_payment", headers: author_auth_headers
      expect(response).to have_http_status(400)
    end

    it 'in reject_payment' do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/reject_payment", headers: author_auth_headers
      expect(response).to have_http_status(400)
    end

    it 'in forgive' do
      credit = Fabricate(:credit, author: author, issued: issued)
      post "#{url}/#{credit.id}/forgive", headers: author_auth_headers
      expect(response).to have_http_status(400)
    end
  end
end