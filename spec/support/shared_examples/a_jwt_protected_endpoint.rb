shared_examples 'a JWT protected endpoint' do |verb|
  context 'without a JWT' do
    let(:headers) { nil }

    it 'responds with a 401' do
      make_request(verb)

      expected_error(status: 401, message: 'Nil JSON web token')
    end
  end

  context 'when the JWT has expired' do
    let(:jwt) { JsonWebToken.encode(payload: { user_id: user.id }, expiration: -10) }

    it 'responds with a 401' do
      make_request(verb)

      expected_error(status: 401, message: 'Signature has expired')
    end
  end

  context 'when JWT\'s user ID is invalid' do
    let(:jwt) { JsonWebToken.encode(payload: { user_id: 'not_an_id' }) }

    it 'responds with a 404' do
      make_request(verb)

      expected_error(status: 404, message: "Couldn't find User with 'id'=not_an_id")
    end
  end

  context 'when the JWT has been tampered with' do
    it 'responds with a 401' do
      jwt[-1] = '?'

      make_request(verb)

      expected_error(status: 401, message: 'Signature verification raised')
    end
  end
end

def make_request(verb)
  if verb == :delete
    delete path, headers: headers
  end
end
