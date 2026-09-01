class CategoriesController < ApplicationController
  before_action :set_category, only: [:destroy]

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      # Modificado: Ahora redirige a la página principal (root_path) en lugar de new_product_path
      redirect_to root_path, notice: "¡Categoría creada con éxito!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to root_path, notice: "¡Categoría eliminada exitosamente!"
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end