class History < ApplicationRecord
  enum transaction_type: [:withdraw, :deposit, :transfer]

  validates_presence_of :source_id

  belongs_to :source, class_name: "Account", foreign_key: :source_id
  belongs_to :destination, class_name: "Account", foreign_key: :destination_id, optional: true

  delegate *%w{address username},  to: :source, prefix: true, allow_nil: true

  def self.add_histroy(source, destination, transaction_type, amount)
    transaction_token = SecureRandom.hex(10)
    case transaction_type
    when :withdraw
      self.create!(source_id: source.id, amount: -1 * amount, transaction_type: transaction_type, message: "Withdraw #{amount.to_f} ", transaction_token: transaction_token)
    when :deposit
      self.create!(source_id: source.id, amount: amount, transaction_type: transaction_type, message: "Deposit #{amount.to_f}", transaction_token: transaction_token)
    when :transfer
      raise 'Add Histroy error, need to provide a transfer account' if destination.nil?
      self.create!(source_id: source.id, destination_id: destination.id , amount: -1 * amount, transaction_type: transaction_type, message: "transfer #{amount.to_f} to #{destination.address}", transaction_token: transaction_token)
      self.create!(source_id: destination.id, destination_id: source.id , amount: amount, transaction_type: transaction_type, message: "#{source.address}(#{source.username}) transfer you #{amount.to_f}", transaction_token: transaction_token)
    end
  end

end
