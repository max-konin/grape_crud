require 'spec_helper'

RSpec.describe GrapeCRUD::Actions::IndexProcess do
  let(:model_class) { double('MyModel') }
  let(:action) { described_class.new(input: { model_class: model_class }) }

  describe '#with_searcher' do
    subject { action.with_searcher(searcher) }

    context 'when pass object with "results" method' do
      let(:searcher) { double 'MySearcher' }
      before { allow(searcher).to receive(:results).and_return [] }

      it { is_expected.to be_success }
      it { expect(subject.results.searcher).to eq searcher }
    end
    context 'when pass object without "results" method' do
      let(:searcher) { double 'MySearcher' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#filter' do
    subject { action.filter }
    let(:action) do
      described_class.new input: {
        model_class: model_class,
        searcher: searcher
      }
    end
    let(:searcher) { double 'MySearcher' }

    before { allow(searcher).to receive(:results).and_return [] }

    it { is_expected.to be_success }
    it { expect(subject.results.records).to eq [] }
    it 'call results mthd of searcher' do
      subject
      expect(searcher).to have_received(:results).with(model_class)
    end
  end

  describe '#sort' do
    let(:action) { described_class.new(input: { records: model_class }) }

    subject { action.sort('field', direction) }
    before { allow(model_class).to receive(:order).and_return [] }

    context 'when directions is "desc"' do
      let(:direction) { 'desc' }

      it { is_expected.to be_success }
      it { expect(subject.results.records).to eq [] }
      it 'call order mthd of model class with "field desc"' do
        subject
        expect(model_class).to have_received(:order).with('field desc')
      end
    end
    context 'when directions is "asc"' do
      let(:direction) { 'asc' }

      it { is_expected.to be_success }
      it { expect(subject.results.records).to eq [] }
      it 'call order mthd of model class with "field asc"' do
        subject
        expect(model_class).to have_received(:order).with('field asc')
      end
    end
    context 'when directions is not "desc" or "asc"' do
      let(:direction) { 'fake' }

      it { is_expected.to be_success }
      it { expect(subject.results.records).to eq [] }
      it 'call order mthd of model class with "field desc"' do
        subject
        expect(model_class).to have_received(:order).with('field desc')
      end
    end
  end

  describe '#pagination' do
    let(:records) { (0..50).to_a }
    let(:action) { described_class.new(input: { records: records }) }
    let(:per_page) { nil }

    subject { action.paginate 'page' => page, 'per_page' => per_page }

    context 'when pass "page" params' do
      let(:page) { 1 }
      context 'with per_page' do
        let(:per_page) { 5 }
        it { is_expected.to be_success }
        it { expect(subject.results.records.size).to eq 5 }
      end
      context 'without per page' do
        let(:per_page) { nil }
        it { is_expected.to be_success }
        it 'paginates with default per_page' do
          expect(subject.results.records.size).to eq 30
        end
      end
    end

    context 'when does not pass "page" params' do
      let(:page) { nil }
      it { is_expected.to be_success }
      it 'does not paginate records' do
        expect(subject.results.records).to eq records
      end
    end
  end
end
