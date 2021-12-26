# frozen_string_literal: true

shared_context 'new user' do
  let(:email)    { 'valid@mail.com' }
  let(:password) { 'password' }
  let(:params)   { { email: email, password: password } }
  let(:headers)  { { 'Authorization': "Token token=#{ENV['client_id']}" } }
end
