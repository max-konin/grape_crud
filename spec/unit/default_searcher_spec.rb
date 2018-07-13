require 'spec_helper'

RSpec.describe GrapeCRUD::DefaultSearcher do
  describe '#results' do
    let(:model) { double 'MyModel' }
    let(:query) { double 'MyQueryObject' }
    let(:searcher) { described_class.new(filters: filters) }
    before { allow(model).to receive(:where).and_return query }

    subject { searcher.results model }

    context 'with filters' do
      let(:filters) { { name: 'name' } }

      it { is_expected.to eq query }
    end

    context 'without filters' do
      let(:filters) { nil }

      it { is_expected.to eq model }
    end
  end
end
