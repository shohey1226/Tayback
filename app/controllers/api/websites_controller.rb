class Api::WebsitesController < ApiController
  before_action :set_api_website, only: [:show, :edit, :update, :destroy]

  # GET /api/websites
  # GET /api/websites.json
  def index
    @api_websites = Website.all
  end

  # GET /api/websites/1
  # GET /api/websites/1.json
  def show
  end

  # GET /api/websites/new
  def new
    @api_website = Api::Website.new
  end

  # GET /api/websites/1/edit
  def edit
  end

  # POST /api/websites
  # POST /api/websites.json
  def create
    @api_website = Api::Website.new(api_website_params)

    respond_to do |format|
      if @api_website.save
        format.html { redirect_to @api_website, notice: 'Website was successfully created.' }
        format.json { render :show, status: :created, location: @api_website }
      else
        format.html { render :new }
        format.json { render json: @api_website.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/websites/1
  # PATCH/PUT /api/websites/1.json
  def update
    respond_to do |format|
      if @api_website.update(api_website_params)
        format.html { redirect_to @api_website, notice: 'Website was successfully updated.' }
        format.json { render :show, status: :ok, location: @api_website }
      else
        format.html { render :edit }
        format.json { render json: @api_website.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/websites/1
  # DELETE /api/websites/1.json
  def destroy
    @api_website.destroy
    respond_to do |format|
      format.html { redirect_to api_websites_url, notice: 'Website was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_website
      @api_website = Api::Website.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def api_website_params
      params[:api_website]
    end
end
