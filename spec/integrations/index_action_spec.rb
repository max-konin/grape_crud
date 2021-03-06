require 'spec_helper'

RSpec.describe GrapeCRUD do
  describe '#add_index_action' do
    let(:response_body) { JSON.parse(last_response.body) }

    def app
      subject
    end

    def build_api(authorize)
      Class.new(Grape::API) do
        include GrapeCRUD

        format :json

        resource :articles do
          helpers do
            def model
              Article
            end

            def current_user
              nil
            end
          end

          desc 'returns list of articles'
          params do
            optional :filter, type: Hash do
              optional :name, type: String
            end
          end
          add_index_action authorize: authorize
        end
      end
    end

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
            include GrapeCRUD
            format :json

            resource :article do
              helpers do
                def model
                  Article
                end

                def base_query
                  Article.where(name: 'a')
                end

                def policy
                  policy
                end
              end

              desc 'returns list of articles'
              params do
                optional :filter, type: Hash do
                  optional :name, type: String
                end
              end
              add_index_action
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
      context 'when user has permission' do
        subject { build_api true }

        it_behaves_like 'an index action'
      end
      context 'when user has not permission' do
        subject { build_api true }

        before do
          allow_any_instance_of(ArticlePolicy).to 
            receive(:index?).and_return(false)
          get '/articles'
        end
        it { expect(last_response.status).to eq 401 }
      end
    end
    context 'without authorization' do
      subject { build_api false }

      it_behaves_like 'an index action'
    end
  end
end
