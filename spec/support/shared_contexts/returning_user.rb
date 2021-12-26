# frozen_string_literal: true

shared_context 'returning user' do
  let(:user)     { create(:user) }
  let(:email)    { user.email }
  let(:password) { user.password }
  let(:headers)  { { 'Authorization': "Token token=#{ENV['client_id']}" } }
end
