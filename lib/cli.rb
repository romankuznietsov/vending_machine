class Cli
  def initialize
    @vending_machine = VendingMachine.new
  end

  def start
    loop do
      print_menu_and_get_selection
    end
  end

  private

  def print_menu_and_get_selection
    print_divider
    puts "Menu:"
    @vending_machine.stock.each do |name, props|
      puts "#{name} - $#{props[:price]} #{props[:quantity].zero? ? '(out of stock)' : ''}"
    end
    print_divider
    puts "Select an item by typing its name and pressing [Enter]"
    item_name = gets.strip

    response = @vending_machine.select_item(item_name)

    case response
    when :item_already_selected
      puts 'An item has already been selected'
      accept_coins
    when :item_unknown
      puts "Unknown item '#{item_name}'"
      return
    when :item_out_of_stock
      puts "'#{item_name}' is out of stock"
      return
    when :item_selected
      puts "You selected '#{item_name}'"
      accept_coins
    end
  end

  def accept_coins
    loop do
      print_divider
      puts "Available coins: #{VendingMachine::COINS.map(&:to_s).join(', ')}"
      puts "Type coin value and press [Enter]"
      coin = gets.strip.to_i

      unless VendingMachine::COINS.include?(coin)
        puts 'Invalid coin'
        next
      end

      response = @vending_machine.insert_coin(coin)

      case response
      when :item_not_selected
        puts 'No item has been selected'
      when :coin_accepted
        puts 'Coin accepted'
        puts "Credit: #{@vending_machine.credit}"
      when :item_dispensed
        puts 'Your item has been dispensed'
        puts "Change given: #{@vending_machine.returned_coins.map(&:to_s).join(', ')}"
        @vending_machine.take_returned_coins
        break
      when :cannot_give_change
        puts 'Cannot give change'
        puts "Coins returned: #{@vending_machine.returned_coins.map(&:to_s).join(', ')}"
        @vending_machine.take_returned_coins
        break
      end
    end
  end

  def print_divider
    puts '=' * 80
  end
end
