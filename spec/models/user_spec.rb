require 'rails_helper'

describe User do
  let(:email)    { 'email@email.com' }
  let(:password) { 'password' }

  subject { User.create(email: email, password: password) }

  describe 'field validations' do
    it 'is valid with all attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without an email' do
      subject.update(email: nil)

      expect(subject).to_not be_valid
    end

    it 'is invalid without a password' do
      subject.update(password: nil)

      expect(subject).to_not be_valid
    end

    it 'is invalid without a unique email' do
      subject
      copy_cat = User.new(email: email, password: password)

      expect(copy_cat).to_not be_valid
    end
  end
end
