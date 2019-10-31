class API::V1::FeaturedWorksController <  ActionController::Base
  #defines :limit, :default_limit, :models_to_search, :switche_tenant
  include Ubiquity::ApiControllerUtilityMethods
  include Ubiquity::ApiErrorHandlers

  def create
     @featured_work = FeaturedWork.new(work_id: params[:work_id], order: params[:order])

     respond_to do |format|
       if @featured_work.save
         format.json { render json: {code: 201,  status: :created} }
       else
         format.json { render json: @featured_work.errors, code: 422, status: :unprocessable_entity }
       end
     end
   end

   def destroy
     @featured_work = FeaturedWork.find_by(work_id: params[:work_id])
     if @featured_work
       # Handle the case where a separate request may have already
       # destroyed this work
       @featured_work.destroy
     end

     respond_to do |format|
       format.json { head :no_content }
     end
   end

end
