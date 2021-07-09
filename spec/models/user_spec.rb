require 'rails_helper'

describe User do
  let(:email)    { 'email@email.com' }
  let(:password) { 'password' }

  subject!(:user) { User.create(email: email, password: password) }

  describe 'field validations' do
    it 'is valid with all attributes' do
      expect(user).to be_valid
    end

    it_behaves_like 'it is invalid without', [:email, :password]

    it 'is invalid without a unique email' do
      copy_cat = User.new(email: email, password: password)

      expect(copy_cat).to_not be_valid
    end
  end

  describe '#authenticate!' do
    context 'with a correct password' do
      it 'does not raise an error' do
        expect { user.authenticate!(password) } .to_not raise_error
      end
    end

    context 'with an incorrect password' do
      it 'raises an error' do
        expect { user.authenticate!('incorrect_password') } .to \
          raise_error AuthenticationError::InvalidPassword
      end
    end
  end

  describe 'relationships' do
    it { should have_many :accounts }
  end
end
