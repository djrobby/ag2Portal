require_dependency "ag2_admin/application_controller"

module Ag2Admin
  class ReindexController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:ridx_reindex]

    # Reindex model
    def ridx_reindex
      m = params[:m]
      m = m.split(",")
      code = I18n.t(:reindex_empty)
      if m != ""
        m.each do |mdl|
          code = reindex_model(mdl)
          break if code == I18n.t(:reindex_error, var: mdl)
        end
      end
      @json_data = { "code" => code }
      authorize! :ridx_reindex, @json_data
      render json: @json_data
    end

    def index
      @models = reindexable_models
    end
  end
end
