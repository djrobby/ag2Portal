require_dependency "ag2_human/application_controller"

module Ag2Human
  class Ag2TimerecordController < ApplicationController
    before_filter :authenticate_user!

    def index
      authorize! :update, TimeRecord

      # Sunspot special:
      # Must use Sunspot index always for update/re-index current data,
      # because data is added externally (ag2TimeRecord Client) and is not indexed.
      # (at rails console, use Sunspot.commit!)
      #
      # It's possible to re-index only an instance variable:
      #   @time_records = TimeRecord.all
      #   @time_records.index
      #
      # The slower all-in-one model re-index:
      #   TimeRecord.index
      # Faster in-batches re-index:
      if session[:reindex] == true
        TimeRecord.find_in_batches do |b|
          Sunspot.index(b)
        end
      end
      session[:reindex] = nil
    end
  end
end
