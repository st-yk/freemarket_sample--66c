class ItemsController < ApplicationController
  before_action :set_category, only: [:new, :create, :edit, :update]
  before_action :set_item, only: [:edit, :update, :destroy, :purchase, :pay, :done]
  before_action :move_to_root, except: [:show]

  require 'payjp'


  def new
    @item = Item.new
    @item.images.new

    def get_category_children
      @category_children = Category.find_by(id: "#{params[:parent_id]}", ancestry: nil).children
    end
  
    def get_category_grandchildren
      @category_grandchildren = Category.find("#{params[:child_id]}").children
    end

  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      redirect_to new_item_path
    end
  end

  def edit

    def get_category_children
      @category_children = Category.find_by("#{params[:parent_name]}", ancestry: nil).children
    end
  
    def get_category_grandchildren
      @category_grandchildren = Category.find("#{params[:child_id]}").children
    end
  end

  def update
    if @item.update(item_params)
      redirect_to root_path
    else 
      redirect_to edit_item_path
    end
  end


  def show
    @item = Item.find(params[:id])
    @images = @item.images
    @saler_items = Item.where(saler: @item.saler).limit(6)
    @brand_items = Item.where(brand: @item.brand).limit(6)
  end

  def edit
  end

  def destroy
    if @item.destroy
      redirect_to root_path
    else 
      redirect_to item_path(item)
    end
  end

  def purchase
  end


  def pay
    Payjp.api_key =ENV['PAYJP_PRIVATE_KEY']
    Payjp::Charge.create(
      amount: @item.price, # 決済する値段
      card: params['payjp-token'], # フォームを送信すると作成・送信されてくるトークン
      currency: 'jpy'
    )
    redirect_to done_item_path(@item)
  end


  def done
    @item.update(buyer_id: current_user.id)
  end

private
  
  def item_params
    params.require(:item).permit(:name,:detail,:brand_id, :price, :shipping_date,:condition,:image, :delivery_method, :region, :postage,:category_id, images_attributes: [:image, :_destroy, :id]).merge(saler_id: current_user.id,buyer_id: nil)

  end

  def usre_params
    params.require(:user).permit(:email, :encrypted_password, :nickname,:first_name, :last_name, :first_name_rattle,:birthyear,:birthmonth,:birthday, :introduction,:image)
  end

  def brand_params
    params.premit(:id,:name)
  end

  def set_category
    @category_parent_array = []
      Category.where(ancestry: nil).each do |parent|
        @category_parent_array << parent
      end
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def move_to_root
    redirect_to root_path unless user_signed_in?
  end
end