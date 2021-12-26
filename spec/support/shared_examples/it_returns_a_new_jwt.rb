shared_examples 'it returns a new jwt' do
  it 'returns a new jwt' do
    expect { JsonWebToken.decode(token: json_response[:token]) }.to_not raise_error
  end
end
