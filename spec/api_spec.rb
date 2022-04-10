require 'rails_helper'

RSpec.describe "API Test", type: :request do
  describe "Account successful" do
    context "operation successful" do
      it 'create account' do
        random = [*'a'..'z',*'0'..'9'].sample(8).join
        post accounts_path, params: {
          username: random,
          email: "#{random}@gamil.com",
          password: "123456",
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "0"
      end

      it 'login' do
        random = [*'a'..'z',*'0'..'9'].sample(8).join
        account = Account.create(
          username: random,
          email: "#{random}@gamil.com",
          password: "123456",
        )
        post accounts_path, params: {
          username: random,
          email: "#{random}@gamil.com",
          password: "123456",
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "0"
      end
    end

    context "operation failed" do
      it "is invalid without username, email or password in create account" do
        random = [*'a'..'z',*'0'..'9'].sample(8).join
        post accounts_path, params: {
          username: random,
          email: "#{random}@gamil.com",
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "1"

        post accounts_path, params: {
          username: random,
          password: "123456"
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "1"

        post accounts_path, params: {
          email: "#{random}@gamil.com",
          password: "123456"
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "1"
      end

      it "is invalid without username, email or password in login, " do
        random = [*'a'..'z',*'0'..'9'].sample(8).join
        account = Account.create(
          username: random,
          email: "#{random}@gamil.com",
          password: "123456",
        )
        post login_path, params: {
          username: random,
          email: "#{random}@gamil.com",
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "1"

        post login_path, params: {
          email: "#{random}@gamil.com",
          password: "123456",
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "1"

        post login_path, params: {
          username: random,
          password: "123456",
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "1"

        post login_path, params: {
          username: random,
          email: "#{random}@gamil.com",
          password: "12345a6",
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "1"
      end
    end
  end

  describe "Transfer operation" do
    before do
      destination_random = [*'a'..'z',*'0'..'9'].sample(8).join
      @destination_account =  Account.create(
        username: destination_random,
        email: "#{destination_random}@gamil.com",
        password: "123456",
        balance: 100
      )

      random = [*'a'..'z',*'0'..'9'].sample(8).join
      @account = Account.create(
        username: random,
        email: "#{random}@gamil.com",
        password: "123456",
        balance: 100
      )
      post login_path, params: {
        username: random,
        email: "#{random}@gamil.com",
        password: "123456",
      }

      @token = JSON.parse(response.body)["data"]["token"]
    end
    context "operation successful" do
      it "User deposit money into her wallet" do
        post deposit_path, params: {
          amount: 20,
          HTTP_AUTHENTICATE: @token
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "0"
        expect(json["data"]["balance"].to_d).to eq 120.to_d
      end

      it "User withdraw money from her wallet" do
        post withdraw_path, params: {
          amount: 20,
          HTTP_AUTHENTICATE: @token
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "0"
        expect(json["data"]["balance"].to_d).to eq 80.to_d
      end

      it "User send money to another user" do

        post transfer_path, params: {
          destination_address: @destination_account.address,
          amount: 20,
          HTTP_AUTHENTICATE: @token
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "0"
        expect(json["data"]["balance"].to_d).to eq 80.to_d
      end

      it "Get Transfer histories" do
        @account.deposit(10)
        get "/histories", params: {HTTP_AUTHENTICATE: @token}
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "0"
        expect(json["data"].length).to eq 1
      end

      it "Check account info" do
        get "/check", params: {HTTP_AUTHENTICATE: @token}
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "0"
        expect(json["data"]["address"]).to eq @account.address
        expect(json["data"]["balance"].to_d).to eq @account.balance.to_d
      end

    end

    context "operation failed" do
      it "User deposit money into her wallet" do
        post deposit_path, params: {
          amount: -20,
          HTTP_AUTHENTICATE: @token
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "2"
      end

      it "User withdraw money from her wallet" do
        post withdraw_path, params: {
          amount: 200,
          HTTP_AUTHENTICATE: @token
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "3"
      end

      it "User send money to another user" do

        post transfer_path, params: {
          amount: 20,
          HTTP_AUTHENTICATE: @token
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "4"

        post transfer_path, params: {
          destination_address: "adfadsfads",
          amount: 20,
          HTTP_AUTHENTICATE: @token
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "104"

        post transfer_path, params: {
          destination_address: @destination_account.address,
          amount: 200,
          HTTP_AUTHENTICATE: @token
        }
        json = JSON.parse(response.body)
        expect(json["code"]).to eq "6"
      end
    end

  end

end