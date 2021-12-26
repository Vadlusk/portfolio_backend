# frozen_string_literal: true

shared_examples 'a JWT protected endpoint' do |verb|
  context 'without a JWT' do
    let(:headers) { nil }

    it 'responds with a 401' do
      make_request(verb)

      expected_error(status: 401, message: 'Nil JSON web token')
    end
  end

  context 'with an expired JWT' do
    let(:jwt) { JsonWebToken.encode(payload: { user_id: user.id }, expiration: -10) }

    it 'responds with a 401' do
      make_request(verb)

      expected_error(status: 401, message: 'Signature has expired')
    end
  end

  context 'with an invalid user ID in the JWT' do
    let(:jwt) { JsonWebToken.encode(payload: { user_id: 'not_an_id' }) }

    it 'responds with a 404' do
      make_request(verb)

      expected_error(status: 404, message: "Couldn't find User with 'id'=not_an_id")
    end
  end

  context 'with a compromised JWT' do
    it 'responds with a 401' do
      jwt[-1] = '?'

      make_request(verb)

      expected_error(status: 401, message: 'Signature verification raised')
    end
  end
end

def make_request(verb)
  case verb
  when :delete
    delete path, headers: headers
  when :get
    get path, headers: headers
  when :post
    post path, headers: headers
  end
end
