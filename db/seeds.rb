require 'csv'
require 'attr_extras'

# Populates the database with the CSV files Nathan gave me
# We get the exchange and currency info from the file name
# and the rest from the actual CSV ccontents
class ExchangeInfo
  rattr_initialize :exchange, :buy_currency, :sell_currency
end

def parse_name(name)
  matches = /(\w+)-(\w{3})(\w{3})\.csv$/.match(name)
  ExchangeInfo.new(matches[1], matches[2], matches[3])
end

Dir.glob('db/seeds/*.csv') do |file|
  metadata = parse_name(file)

  CSV.foreach(file, headers: true) do |row|
    Order.create!(exchange: metadata.exchange,
                  side:  row['side'],
                  buy_currency: metadata.buy_currency,
                  sell_currency: metadata.sell_currency,
                  price: row['price'],
                  quantity: row['quantity'])
  end
end