class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  def show
  end

  # GET /accounts/new_cc
  def new_cc
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  def history

  end

  def profile

  end

  def withdraw

  end

  def add_fund
    render layout: false
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)
    @account.user = current_user
    if current_user.balanced_customer_id
      balanced_customer = Balanced::Customer.find(current_user.balanced_customer_id)
    else
      balanced_customer = Balanced::Customer.new.save
      current_user.balanced_customer_id = balanced_customer.uri
      current_user.save!
    end

    balanced_customer.add_card(@account.ext_account_id)
    if params[:amount].present?
      amount = params[:amount].gsub(/\D\./, '').to_f
      balanced_customer.debit(amount: (amount*100).to_i, source_uri: @account.ext_account_id)
    end

    if @account.save
      render json: {status: 201, account: @account}
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      redirect_to @account, notice: 'Account was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
    redirect_to accounts_url, notice: 'Account was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
      params.require(:account).permit(:ext_account_id)
    end
end
