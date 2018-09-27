require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe 'GET /', type: :request do
  let(:user) {Fabricate(:user)}
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers(
        {'Accept': 'application/json', 'Content-Type': 'application/json'},
        user
    )
  end
  let(:url) {'/'}

  context 'test info' do
    before do
      get url, headers: auth_headers
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end
  end
end
