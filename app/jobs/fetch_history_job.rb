# frozen_string_literal: true

class FetchHistoryJob < ApplicationJob
  queue_as :default

  def perform(account, user)
    account.fetch_history

    ActionCable.server.broadcast "history_update_channel_#{account.id}", {
      account: {
        id: account.id,
        name: account.name,
        nickname: account.nickname,
        transactions: account.transactions
      },
      totals: user.totals
    }.to_json
  end
end
