require 'spec_helper'

RSpec.describe GrapeCRUD do
  describe '#add_index_action' do
    let(:response_body) { JSON.parse(last_response.body) }

    def app
      subject
    end

    subject do
      Class.new(Grape::API) do
        extend GrapeCRUD
        format :json

        resource :article do
          helpers do
            def model
              Article
            end
          end

          desc 'returns list of articles'
          params :filter do
            optional :name, type: String
          end
          add_index_action options
        end
      end
    end

    let(:options) { { authorize: authorize } }

    RSpec.shared_examples 'an index action' do
      let!(:article_a) { Article.create name: 'a' }
      let!(:article_b) { Article.create name: 'b' }

      before { get '/articles', params: params }

      context 'without params' do
        let(:params) { {} }
        let(:expected_response) do
          {
            'articles' => [
              { 'id' => article_a.id, 'name' => 'a' },
              { 'id' => article_b.id, 'name' => 'b' }
            ]
          }
        end
        it 'returns two serialized articles' do
          expect(response_body).to eq expected_response
        end
      end

      context 'with filters' do
        let(:params) { { name: 'a' } }
        let(:expected_response) do
          {
            'articles' => [
              { 'id' => article_a.id, 'name' => 'a' }
            ]
          }
        end
        it 'returns one serialized articles' do
          expect(response_body).to eq expected_response
        end
      end

      context 'with pagination' do
        let(:params) { { page: 1, per_page: 1 } }
        let(:expected_response) do
          {
            'articles' => [
              { 'id' => article_a.id, 'name' => 'a' }
            ]
          }
        end
        it 'returns first serialized articles' do
          expect(response_body).to eq expected_response
        end
      end

      context 'with custom base_query' do
        subject do
          Class.new(Grape::API) do
            extend GrapeCRUD
            format :json

            resource :article do
              helpers do
                def model
                  Article
                end

                def base_query
                  Article.where(name: 'a')
                end
              end

              desc 'returns list of articles'
              params :filter do
                optional :name, type: String
              end
              add_index_action options
            end
          end
        end
        let(:params) { {} }
        let(:expected_response) do
          {
            'articles' => [
              { 'id' => article_a.id, 'name' => 'a' }
            ]
          }
        end
        it 'returns first serialized articles' do
          expect(response_body).to eq expected_response
        end
      end
    end

    context 'with authorization' do
      let(:authorize) { true }
      context 'when user has permission' do
        it_behaves_like 'an index action'
      end
      context 'when user ha not permission' do
        before { get '/articles' }
        it { expect(last_response.status).to eq 401 }
      end
    end
    context 'without authorization' do
      let(:authorize) { false }

      it_behaves_like 'an index action'
    end
  end
end
