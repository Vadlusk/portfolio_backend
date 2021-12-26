# frozen_string_literal: true

class HistoryUpdateChannel < ApplicationCable::Channel
  def subscribed
    # if !params[:accountId] raise...
    account_id = params[:accountId]

    # account = current_user.accounts.find(account_id)
    # if !account raise...

    stream_from "history_update_channel_#{account_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
