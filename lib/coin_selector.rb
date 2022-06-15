module CoinSelector
  module_function

  def select_coins(bank, amount)
    return [] if amount.zero?

    possible_next_coins = bank.keys.select do |coin|
      bank[coin].positive? && coin <= amount
    end

    return if possible_next_coins.none?

    possible_next_coins.map do |coin|
      remaining_bank = bank.dup
      remaining_bank[coin] -= 1
      remaining_coins = select_coins(remaining_bank, amount - coin)
      remaining_coins && ([coin] + remaining_coins)
    end.reject(&:nil?).sort_by(&:length).first
  end
end
