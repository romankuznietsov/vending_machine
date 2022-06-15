require 'spec_helper'

RSpec.describe VendingMachine do
  subject { described_class.new(stock: stock, bank: bank) }

  describe '#select_item' do
    let(:stock) do
      {
        'Foo' => { price: 1, quantity: 1 },
        'Bar' => { price: 1, quantity: 1 },
        'Baz' => { price: 1, quantity: 0 }
      }
    end

    let(:bank) { {} }

    it 'selects an item' do
      expect(subject.select_item('Foo')).to eq(:item_selected)
      expect(subject.selection).to eq('Foo')
    end

    it 'does not select unknown items' do
      expect(subject.select_item('Unknown')).to eq(:item_unknown)
      expect(subject.selection).to be_nil
    end

    it 'does not select item that is out of stock' do
      expect(subject.select_item('Baz')).to eq(:item_out_of_stock)
      expect(subject.selection).to be_nil
    end

    context 'item already selected' do
      before { subject.select_item('Foo') }

      it 'does not change selection' do
        expect(subject.select_item('Bar')).to eq(:item_already_selected)
        expect(subject.selection).to eq('Foo')
      end
    end
  end

  describe '#insert_coin' do
    let(:stock) { { 'Foo' => { price: 100, quantity: 1 } } }
    let(:bank) { { 50 => 2 } }

    context 'item not selected' do
      it 'does not accept the coin' do
        expect(subject.insert_coin(100)).to eq(:item_not_selected)
        expect(subject.credit).to eq(0)
      end
    end

    context 'item selected' do
      before { subject.select_item('Foo') }

      it 'accepts the coin' do
        expect(subject.insert_coin(50)).to eq(:coin_accepted)
        expect(subject.credit).to eq(50)
      end

      it 'dispenses the item and resets when enough coins inserted' do
        expect(subject.insert_coin(50)).to eq(:coin_accepted)
        expect(subject.insert_coin(50)).to eq(:item_dispensed)
        expect(subject.selection).to be_nil
        expect(subject.credit).to eq(0)
        expect(subject.returned_coins).to be_none
        expect(subject.stock.dig('Foo', :quantity)).to eq(0)
      end

      it 'gives change if possible' do
        expect(subject.insert_coin(200)).to eq(:item_dispensed)
        expect(subject.returned_coins).to match_array([50, 50])
        subject.take_returned_coins
        expect(subject.returned_coins).to be_none
      end

      it 'returns coins if cannot give change' do
        expect(subject.insert_coin(300)).to eq(:cannot_give_change)
        expect(subject.returned_coins).to match_array([300])
      end
    end
  end
end
