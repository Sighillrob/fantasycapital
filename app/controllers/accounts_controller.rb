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
    @transactions = Transaction.where(user_id: current_user.id)

    # Temporary code - REMOVE when we have real code to add transactions
    if @transactions.length == 0
      # Create random number of transactions for current user
      n_to_create = rand(10..30)
      (0..n_to_create).each do
        rx = Transaction.random_transaction(current_user)
        if rx != nil
          rx.save
        end
      end
      @transactions = Transaction.where(user_id: current_user.id)
    end
    # END Temporary code to create random transactions

    @transactions = @transactions.order(created_at: :asc)
  end

  def profile

  end

  def withdraw

  end

  def add_fund
    @credit_card = current_user.default_card
    render layout: false
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
