class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :adjust_stock]

  def index
    @products = Product.includes(:category).order(created_at: :desc)
  end

  def show
  end

  def new
    @product = Product.new
    @categories = Category.all
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to products_path, notice: "Producto creado exitosamente."
    else
      @categories = Category.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: "Producto actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Producto eliminado exitosamente."
  end

  def adjust_stock
    change = params[:change].to_i
    new_stock = [@product.stock + change, 0].max

    if @product.update(stock: new_stock)
      respond_to do |format|
        format.html { redirect_to products_path }
        format.turbo_stream
      end
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :sku, :price, :stock, :low_stock_threshold, :category_id)
  end
end