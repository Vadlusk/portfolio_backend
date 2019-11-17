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
end
