class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery :except => :create

  #sbin/bearerbox -v 0 smskannel.conf
  #sbin/smsbox -v 0 smskannel.conf

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    #users
    flag = params[:user][:name].split('#')[0]
    role = params[:user][:name].split('#')[1]
    name = params[:user][:name].split('#')[2]
    location = params[:user][:name].split('#')[3]
    phone = params[:user][:phone]

    #products
    product_name = params[:user][:name].split('#')[1]
    price = params[:user][:name].split('#')[2]

    #whitelist
    maize_set = ['mahindi', 'maize']
    beans_set = ['maharagwe', 'mbosho', 'beans']
    potatoe_set = ['potatoe', 'viazi', 'waru']

    begin
      if flag.downcase == 'register'
        if User.exists?(phone: phone)
          if role.downcase == 'farmer'
            if User.exists?(phone: phone, role: '1')
              @user = User.find_by_phone(phone)
              KannelRails.send_message(phone, "You have already been registered for the service as #{@user.name}")
            else
              @user = User.create(name: name, phone: phone, role: '1')
              if @user.save
                KannelRails.send_message(phone, 'You have successfully been registered as a Farmer to Ukulima Texts.
                                                You can post your rates for maize, beans or potatoe using Sell#Product#price.')
              end
            end
          elsif role.downcase == 'client'
            if User.exists?(phone: phone, role: '2')
              @user = User.find_by_phone(phone)
              KannelRails.send_message(phone, "You have already been registered for the service as #{@user.name}")
            else
              @user = User.create(name: name, phone: phone, role: '2')
              if @user.save
                KannelRails.send_message(phone, 'You have successfully been registered as a Client to Ukulima Texts.
                                               You can query for potatoe, maize or beans using Buy#ProductName')
              end
            end
          end
        else
          if role.downcase =='farmer'
            logger.info 'Registering farmer'
            @user = User.create(name: name, phone: phone, role: '1')
            if @user.save
               KannelRails.send_message(phone, 'You have successfully been registered as a Farmer to Ukulima Texts.
                                                You can post your rates for maize, beans or potatoe using Sell#Product#price.')
            end
          elsif role.downcase == 'client'
            @user = User.create(name: name, phone: phone, role: '2')
            if @user.save
              KannelRails.send_message(phone, 'You have successfully been registered as a Client to Ukulima Texts.
                                               You can query for potatoe, maize or beans using Buy#ProductName')
            end
          else
            KannelRails.send_message(phone, 'Wrong format. Check your spelling and try again with Register#Client#Name
                                            Register#Farmer#Name')
          end
        end
      elsif flag.downcase == 'sell'
        if User.exists?(phone: phone, role: '1')
          @user = User.find_by_phone(phone)
          begin
            if maize_set.include? product_name.downcase
              maize(@user, phone, price)
            elsif beans_set.include? product_name.downcase
              beans(@user, phone, price)
            elsif potatoe_set.include? product_name.downcase
              potatoe(@user, phone, price)
            else
              KannelRails.send_message(phone, 'You can only post for potatoe, beans or maize. Did you misspell? Correct and try again.')
            end
          rescue ActiveRecord::RecordNotUnique
            KannelRails.send_message(phone, 'Already posted the product. Use format Update#Product#Price to make changes.')
          end
        else
          KannelRails.send_message(phone, 'You must register as farmer to post your product.
                                            To Register, send a text with format Register#Farmer#Name')
        end
      elsif flag.downcase == 'buy'
        if User.exists?(phone: phone)
          if Product.exists?(name: product_name.downcase)
            product = Product.find_by_name(product_name.downcase)
            @users = User.in_products(product.id)
            users = []
            @users.each do |user|
              @price = product.prices.where("user_id = ?", user.id).first
              users << "name: #{user.name}, phone no.: #{user.phone}, price: Ksh #{@price.amount unless @price.nil?} per kilo."
            end

            unless users.empty?
              KannelRails.send_message(phone, "Farmers selling #{product_name} #{users.map.with_index {|item, index| "#{index+1}. #{item}"}}")
            else
              KannelRails.send_message(phone, 'No farmer has posted on this product yet.')
            end
          else
            KannelRails.send_message(phone, 'There is no such product. Supported products are potatoe, maize and beans.
                                            Did you misspell? Try again.')
          end
        else
          KannelRails.send_message(phone, 'You are not signed up for Ukulima service. To view products, send text with
                                            format Register#Client#Name')
        end
      elsif flag.downcase == 'update'
        if Product.exists?(name: product_name.downcase)
          product = Product.find_by_name(product_name.downcase)
          user = User.find_by_phone(phone)
          @price = product.prices.where('user_id = ? AND product_id = ?',user.id,product.id).first
          @price.update(amount: price.delete(' '))
          if @price.save
            KannelRails.send_message(phone, "Product successfully updated. New price Ksh #{@price.amount}")
          else
            KannelRails.send_message(phone, 'Product Price must be a digit. Retry setting price to a number.')
          end
        else
          KannelRails.send_message(phone, 'There is no such product. Supported products are potatoe, maize and beans.
                                            Did you misspell? Try again.')
        end
      elsif params[:user][:name].downcase == 'stop'
        if User.exists?(phone: phone)
          user = User.find_by_phone(phone)
          if user.destroy
            KannelRails.send_message(phone, 'You have been unsubscribed from Ukulima service. To signup again,
                                            send text with format Register#Farmer#Name or Register#Client#Name')
          end
        else
          KannelRails.send_message(phone, 'You are not subscribed to Ukulima service.')
        end
      else
        KannelRails.send_message(phone, 'Incorrect format. Please retry with correct format and spelling.')
      end
    end


    #respond_to do |format|
    #  if @user.save
    #    format.html { redirect_to @user, notice: 'User was successfully created.' }
    #    format.json { render action: 'show', status: :created, location: @user }
    #  else
    #    format.html { render action: 'new' }
    #    format.json { render json: @user.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:phone, :name, :location, :role)
    end

    def maize(user, phone, price)
      unless price.nil?
        product = Product.find_by_name('maize')
        product.prices.create(amount: price.delete(' '), user_id: user.id)
        user.products << product
        if @user.save
          KannelRails.send_message(phone, "Successfully posted #{product.name} to Ukulima")
        end
      else
        KannelRails.send_message(phone, "Please supply product price.")
      end
    end

    def beans(user, phone, price)
      unless price.nil?
        product = Product.find_by_name('beans')
        product.prices.create(amount: price.delete(' '), user_id: user.id)
        user.products << product
        if @user.save
          KannelRails.send_message(phone, "Successfully posted #{product.name} to Ukulima")
        end
      else
        KannelRails.send_message(phone, "Please supply product price.")
      end
    end

    def potatoe(user, phone, price)
      unless price.nil?
        product = Product.find_by_name('potatoe')
        product.prices.create(amount: price.delete(' '), user_id: user.id)
        user.products << product
        if @user.save
          KannelRails.send_message(phone, "Successfully posted #{product.name} to Ukulima")
        end
      else
        KannelRails.send_message(phone, "Please supply product price.")
      end
    end
end
