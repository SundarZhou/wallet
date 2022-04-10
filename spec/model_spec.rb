require 'rails_helper'

RSpec.describe "Model Test", type: :model do
  describe "Account verification" do
    it "is valid with a username, email and password" do
      random = [*'a'..'z',*'0'..'9'].sample(8).join
      account = Account.new(
        username: random,
        email: "#{random}@gamil.com",
        password: "123456",
      )
      expect(account).to be_valid
    end

    it "is invalid without a username" do
      account = Account.new(username: nil)
      account.valid?
      expect(account.errors[:username]).to include("can't be blank")
    end

    it "is invalid without an email" do
      account = Account.new(email: nil)
      account.valid?
      expect(account.errors[:email]).to include("can't be blank")
    end

    it "is invalid without a password" do
      account = Account.new(password: nil)
      account.valid?
      expect(account.errors[:password]).to include("can't be blank")
    end


    it "account's address is not nil" do
      random = [*'a'..'z',*'0'..'9'].sample(8).join
      account = Account.new(
        username: random,
        email: "#{random}@gamil.com",
        password: "123456",
      )
      expect(account.address).not_to be_empty
    end
  end

  describe "Transfer verification" do
    before do
      random = [*'a'..'z',*'0'..'9'].sample(8).join
      destination_random = [*'a'..'z',*'0'..'9'].sample(8).join
      @account = Account.create(
        username: random,
        email: "#{random}@gamil.com",
        password: "123456",
        balance: 100
      )
      @destination_account =  Account.create(
        username: destination_random,
        email: "#{destination_random}@gamil.com",
        password: "123456",
        balance: 100
      )
    end

    context "operation successful" do
      it "User can deposit money into her wallet and history generation" do
        @account.deposit(20)
        expect(@account.balance).to eq 120.to_d
        expect(@account.histories.count).to eq 1.to_d
      end

      it "User can withdraw money from her wallet and history generation" do
        @account.withdraw(20)
        expect(@account.balance).to eq 80.to_d
        expect(@account.histories.count).to eq 1.to_d
      end

      it "User can send money to another user and history generation" do
        @account.transfer(@destination_account, 20)
        expect(@account.balance).to eq 80.to_d
        expect(@destination_account.balance).to eq 120.to_d
        expect(@account.histories.count).to eq 1.to_d
        expect(@destination_account.histories.count).to eq 1.to_d
      end
    end

    context "operation failed" do
      it "operation amout must rather than 0" do
        expect { @account.deposit(-20) }.to raise_error(RuntimeError)
        expect { @account.withdraw(-20) }.to raise_error(RuntimeError)
        expect { @account.transfer(@destination_account, -20) }.to raise_error(RuntimeError)
      end

      it "withdraw/transfer amout must rather than account money" do
        expect { @account.withdraw(120) }.to raise_error(RuntimeError)
        expect { @account.transfer(@destination_account, 120) }.to raise_error(RuntimeError)
      end

    end
  end
end
