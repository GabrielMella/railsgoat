# frozen_string_literal: true
class PayController < ApplicationController

  def index
  end

  def update_dd_info
    msg = false
    pay = Pay.new(
      bank_account_num: params[:bank_account_num],
      bank_routing_num: params[:bank_routing_num],
      percent_of_deposit: params[:dd_percent],
      user_id: current_user.id
    )

    msg = true if pay.save!
    respond_to do |format|
      format.json { render json: {msg: msg } }
    end
  end

  def show
   respond_to do |format|
     format.json do
       pay_data = current_user.pay.map do |record|
         record.as_json.merge(
           'bank_account_num' => Encryption.decrypt_sensitive_value(record.bank_account_num) || 'No Data'
         )
       end
       render json: {user: pay_data}
     end
   end
  end

  def destroy
    pay = Pay.find_by_id(params[:id])
    if pay.present? and pay.destroy
      flash[:success] = "Successfully Deleted Entry"
    else
      flash[:error] = "Unable to process that request at this time"
    end
    redirect_to user_pay_index_path
  end
end
