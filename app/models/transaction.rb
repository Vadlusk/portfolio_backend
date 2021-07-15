class Transaction < ApplicationRecord
  enum transaction_type: {
    transfer: 'transfer',
    match: 'match',
    fee: 'fee',
    rebate: 'rebate',
    conversion: 'conversion'
   }

  belongs_to :account
end
