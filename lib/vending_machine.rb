class VendingMachine
  COINS = [ 500, 300, 200, 100, 50, 25 ]

  STOCK = {
    'Foo' => { price: 60, quantity: 1 },
    'Bar' => { price: 100, quantity: 2 },
    'Baz' => { price: 140, quantity: 3 },
    'Qux' => { price: 100, quantity: 0 }
  }

  BANK = {
    100 => 3,
    50 => 5,
    25 => 10
  }

  attr_reader :stock, :selection, :credit, :returned_coins

  def initialize(stock: STOCK, bank: BANK)
    @stock = stock
    @bank = bank
    @credit = 0
    @selection = nil
    @returned_coins = []
  end

  def select_item(item_name)
    return :item_already_selected if @selection
    return :item_unknown unless @stock.key?(item_name)
    return :item_out_of_stock if @stock.dig(item_name, :quantity).zero?

    @selection = item_name
    :item_selected
  end

  def insert_coin(coin)
    return :item_not_selected unless @selection

    add_to_bank(coin)
    @credit += coin

    return dispense_item_and_change if @credit >= selection_price

    :coin_accepted
  end

  def take_returned_coins
    @returned_coins = []
  end

  private

  def dispense_item_and_change
    change = @credit - selection_price

    change_coins = select_coins_from_bank(change)

    if change_coins
      @stock[@selection][:quantity] -= 1
      @returned_coins += change_coins
      reset
      :item_dispensed
    else
      @returned_coins += select_coins_from_bank(@credit)
      reset
      :cannot_give_change
    end
  end

  def selection_price
    @stock.dig(@selection, :price)
  end

  def reset
    @credit = 0
    @selection = nil
  end

  def select_coins_from_bank(amount)
    coins = CoinSelector.select_coins(@bank, amount)
    coins&.each(&method(:remove_from_bank))
    coins
  end

  def add_to_bank(coin)
    @bank[coin] ||= 0
    @bank[coin] += 1
  end

  def remove_from_bank(coin)
    @bank[coin] -= 1
  end
end
