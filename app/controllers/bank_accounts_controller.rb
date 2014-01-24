class BankAccountsController < ApplicationController

  def withdrawal
    @bank_account = current_user.bank_accounts.first
  end

  def withdrawal_post
    bank_account = current_user.bank_accounts.find(params[:bank_id])
    amount = (params[:amount]||'').gsub(/\D/, '').to_i
    BankWithdrawalService.new(current_user, bank_account).withdraw(amount)
    render json: nil, status: :ok
  end

  def new
  end

  def create
    begin
      stripe_token = params[:stripe_token]
      bank_service = BankService.new(current_user, stripe_token)
      StripeCustomerService.new(current_user, stripe_token).ensure!

      unless bank_service.add(bank_account_params)
        render_json_errors(bank_service.bank_account)
        return
      end
      render json: {status: 201}
    rescue ServiceError => e
      render json: {error: e.message}, status: :unprocessable_entity
    end
  end

  private

  def bank_account_params
    params.require(:bank_account).permit(:stripe_id, :name, :last_4)
  end
end
