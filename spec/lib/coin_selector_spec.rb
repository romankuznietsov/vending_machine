require 'spec_helper'

RSpec.describe CoinSelector do
  describe '#select_coins' do
    subject { described_class.select_coins(bank, amount) }

    context 'bank is empty' do
      let(:bank) { {} }
      let(:amount) { 1 }

      it 'cannot select coins' do
        expect(subject).to be_nil
      end
    end

    context 'amount cannot be given with remaining coins' do
      let(:bank) { { 100 => 1 } }
      let(:amount) { 50 }

      it 'cannot select coins' do
        expect(subject).to be_nil
      end
    end

    context 'amount can be given in multiple ways' do
      let(:bank) { { 100 => 1, 50 => 2 } }
      let(:amount) { 100 }

      it 'selects least number of coins' do
        expect(subject).to match_array([100])
      end
    end

    context 'greedy algorithm gives non-optimal result' do
      # A greedy algorithm returns [500, 50, 50]
      # An optimal solution is [300, 300]

      let(:bank) { { 500 => 1, 300 => 2, 50 => 2 } }
      let(:amount) { 600 }

      it 'selects least number of coins' do
        expect(subject).to match_array([300, 300])
      end
    end
  end
end
