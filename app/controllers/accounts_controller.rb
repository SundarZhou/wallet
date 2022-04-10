class AccountsController < ApplicationController
  before_action :authorized, except: [:create, :login]

  # REGISTER
  def create
    @account = Account.create(permit_params)
    if @account.valid?
      token = encode_token({account_id: @account.id})
      render_json({account: account_info, token: token})
    else
      add_message("Please enter username, email, password at the same time!")
      render_error("1")
    end
  end

  # LOGGING IN
  def login
    @account = Account.find_by(username: params[:username], email: params[:email])

    if @account && @account.authenticate(params[:password])
      token = encode_token({account_id: @account.id})
      render_json({account: account_info, token: token})
    else
      add_message("Please enter username, email, correct password at the same time!")
      render_error("1")
    end
  end

  def check
    render_json(account_info)
  end

  def histories
    @histories = @account.
                  histories.preload(:source).
                  order("histories.created_at DESC")

    render_json(@histories.map do |history|
      {
        username: history.source_username,
        address: history.source_address,
        transaction_type: history.transaction_type,
        amount: history.amount,
        message: history.message,
        created_at: history.created_at.strftime("%Y-%m-%d %H:%M:%S")
      }
    end)
  end

  def deposit
    begin
      @account.deposit(params[:amount].to_f)
      add_message("Deposit success")
      render_json(account_info)
    rescue => e
      add_message(e.message)
      render_error('2')
    end
  end

  def withdraw
    begin
      @account.withdraw(params[:amount].to_f)
      add_message("Withdraw success")
      render_json(account_info)
    rescue => e
      add_message(e.message)
      render_error('3')
    end
  end

  def transfer
    if params[:destination_address].nil?
      add_message("Need to provide a transfer account")
      render_error('4')
    elsif (@destination = Account.find_by(address: params[:destination_address])).nil?
      add_message("Transfer account not found")
      render_error('104')
    else
      begin
        @account.transfer(@destination, params[:amount]&.to_d)
        add_message("Transfer success")
        render_json(account_info)
      rescue => e
        add_message(e.message)
        render_error('6')
      end
    end
  end

  private

  def permit_params
    params.permit(:username, :password, :email)
  end

  def account_info
    @account.reload.as_json(only: [:id, :username, :email, :address, :balance])
  end
end
