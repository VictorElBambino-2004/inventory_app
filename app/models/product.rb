class Product < ApplicationRecord
  belongs_to :category

  validates :name, :sku, :price, :stock, presence: true
  validates :sku, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Método para detectar stock bajo según el umbral configurado
  def low_stock?
    stock <= low_stock_threshold.to_i
  end
end