class Account < ApplicationRecord
  has_secure_password
  self.locking_column = :operation_record

  after_initialize :generate_address, if: :new_record?

  validates_presence_of :username, :email, :password_digest, :address
  validates_numericality_of :balance, greater_than_or_equal_to: 0

  has_many :histories, class_name: "History", foreign_key: :source_id

  # Random build 20-bit address
  def generate_address
    self.address = SecureRandom.hex(10)
  end

  def deposit(amount, with_record = true)
    transaction(:deposit, amount, with_record)
  end

  def withdraw(amount, with_record = true)
    precondition_judgment(amount)
    transaction(:withdraw, amount, with_record)
  end


  def transfer(destination, amount)
    precondition_judgment(amount)
    ActiveRecord::Base.transaction do
      self.withdraw(amount, false)
      destination.deposit(amount, false)
      History.add_histroy(self, destination, :transfer, amount)
    end
  end

  private
  def precondition_judgment(amount)
    raise 'Account money not enough' if self.balance < amount
  end

  def transaction(transaction_type, amount, with_record)
    raise 'Amount mush rather than 0' if amount <= 0
    raise 'Non-compliant operation' unless (transaction_type = transaction_type.to_sym).in? [:withdraw, :deposit]

    # Optimistic Locking :operation_record
    retry_times = 3
    begin
      self.reload

      if transaction_type == :withdraw
        precondition_judgment(amount)
        self.balance -= amount
      else
        self.balance += amount
      end
      self.save!
      History.add_histroy(self, nil, transaction_type, amount) if with_record
    rescue ActiveRecord::StaleObjectError => e
      retry_times -= 1
      if retry_times > 0
        sleep(0.3)
        retry
      else
        raise "This account is currently in #{transaction_type} action"
      end
    rescue => e
      raise e.message
    end
  end
end
