require 'rails_helper'

describe User do
  let(:email)    { 'email@email.com' }
  let(:password) { 'password' }
  let!(:user)    { User.create(email: email, password: password) }

  describe 'field validations' do
    it 'is valid with all attributes' do
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user.update(email: nil)

      expect(user).to_not be_valid
    end

    it 'is invalid without a password' do
      user.update(password: nil)

      expect(user).to_not be_valid
    end

    it 'is invalid without a unique email' do
      copy_cat = User.new(email: email, password: password)

      expect(copy_cat).to_not be_valid
    end
  end

  describe '#authenticate_with_error' do
    context 'with a correct password' do
      it 'does not raise an error' do
        expect { user.authenticate_with_error(password) } .to_not \
          raise_error AuthenticationError::InvalidPassword
      end
    end

    context 'with an incorrect password' do
      it 'raises an error' do
        expect { user.authenticate_with_error('incorrect_password') } .to \
          raise_error AuthenticationError::InvalidPassword
      end
    end
  end
end
