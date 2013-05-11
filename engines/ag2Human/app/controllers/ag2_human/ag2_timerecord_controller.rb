require_dependency "ag2_human/application_controller"

module Ag2Human
  class Ag2TimerecordController < ApplicationController
    before_filter :authenticate_user!

    def index
      authorize! :update, TimeRecord
    end
  end
end
