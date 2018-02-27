class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.text exchange
      t.text side
      t.text buy_currency
      t.text sell_currency
      t.real price
      t.real quantity

      t.index %i[buy_currency sell_currency side]
    end
  end
end
