require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_user) { build(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(valid_user).to be_valid
    end

    it 'is not valid without a user_name' do
      valid_user.user_name = nil
      expect(valid_user).not_to be_valid
    end

    it 'is not valid with a user_name longer than 20 characters' do
      valid_user.user_name = 'a' * 21
      expect(valid_user).not_to be_valid
    end

    it 'is not valid without an email' do
      valid_user.email = nil
      expect(valid_user).not_to be_valid
    end

    it 'is not valid if the email is not unique' do
      create(:user, email: 'test@example.com')
      valid_user.email = 'test@example.com'
      expect(valid_user).not_to be_valid
    end

    it 'is not valid without a password' do
      valid_user.password = nil
      expect(valid_user).not_to be_valid
    end

    it 'is not valid if the password is too short' do
      valid_user.password = '1234'
      valid_user.password_confirmation = '1234'
      expect(valid_user).not_to be_valid
    end

    it 'is not valid if password confirmation does not match' do
      valid_user.password_confirmation = 'different'
      expect(valid_user).not_to be_valid
    end
  end
end
