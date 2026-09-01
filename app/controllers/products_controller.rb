class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :adjust_stock]
  before_action :set_categories, only: [:index, :new, :edit, :create, :update, :report]

  def index
    @products = Product.includes(:category)
    
    if params[:query].present?
      @products = @products.where("name ILIKE ? OR sku ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path, notice: "¡Producto creado exitosamente!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: "¡Producto actualizado exitosamente!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "¡Producto eliminado exitosamente!"
  end

  def adjust_stock
    change = params[:change].to_i
    new_stock = [@product.stock + change, 0].max
    @product.update(stock: new_stock)
    redirect_to products_path, notice: "Stock actualizado correctamente."
  end

  def report
    @total_products = Product.count
    @active_products = Product.where(active: true).count
    @low_stock_products = Product.all.select { |p| p.low_stock? } || []
    @total_inventory_value = Product.sum("price * stock") || 0
    @categories_summary = Category.left_joins(:products).group("categories.id").select("categories.name, COUNT(products.id) as products_count")

    respond_to do |format|
      format.html
      format.xlsx { 
        send_data generate_xlsx_report, filename: "reporte-inventario-#{Date.today}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" 
      }
    end
  end

  private

  def generate_xlsx_report
    # Usamos Axlsx (que es lo que instala caxlsx)
    p = Axlsx::Package.new
    wb = p.workbook
    
    wb.add_worksheet(name: "Inventario") do |sheet|
      # Estilos
      title_style = sheet.styles.add_style(b: true, sz: 14, fg_color: "4F46E5")
      header_style = sheet.styles.add_style(b: true, bg_color: "EEEEEE")

      sheet.add_row ["Reporte General de Inventario (#{Date.today})"], style: title_style
      sheet.add_row []
      sheet.add_row ["Total de Productos", @total_products]
      sheet.add_row ["Productos Activos", @active_products]
      sheet.add_row ["Valor Total del Inventario", @total_inventory_value]
      sheet.add_row []
      
      # Cabeceras
      sheet.add_row ["SKU", "Nombre", "Precio", "Stock", "Umbral Stock Bajo", "Estado"], style: header_style
      
      # Datos
      Product.includes(:category).find_each do |p|
        sheet.add_row [p.sku, p.name, p.price, p.stock, p.low_stock_threshold, p.active? ? "Activo" : "Inactivo"]
      end
    end
    
    # Retornar el archivo como binario
    p.to_stream.read
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def set_categories
    @categories = Category.all
  end

  def product_params
    params.require(:product).permit(:name, :description, :sku, :price, :stock, :low_stock_threshold, :category_id, :active)
  end
end