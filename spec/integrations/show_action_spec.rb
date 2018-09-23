require 'spec_helper'

RSpec.describe GrapeCRUD do
  describe '#add_show_action' do
    let(:response_body) { JSON.parse(last_response.body) }
    let!(:article) { Article.create name: 'a' }

    def app
      subject
    end

    def build_api(authorize)
      Class.new(Grape::API) do
        include GrapeCRUD

        format :json

        rescue_from Pundit::NotAuthorizedError do |_e|
          rack_response('{ "status": 401, "message": "Unauthorized." }', 401)
        end

        resource :articles do
          helpers do
            def model
              Article
            end

            def current_user
              nil
            end
          end

          desc 'returns article by ID'
          add_show_action authorize: authorize
        end
      end
    end

    RSpec.shared_examples 'a show action' do
      before { get "/articles/#{article.id}" }
      it { expect(last_response.status).to eq 200 }
      it 'returns serialized article' do
        expect(response_body).to eq(
          'article' => { 'id' => article.id, 'name' => 'a' }
        )
      end
    end

    context 'with auth' do
      subject do
        build_api true
      end

      context 'when user can read a record' do
        it_behaves_like 'a show action'
      end

      context 'when user can not read a record' do
        before do
          article.private = true
          get "/articles/#{article.id}"
        end
        it { expect(last_response.status).to eq 401 }
      end
    end

    context 'without auth' do
      subject do
        build_api false
      end

      context 'when record exists by ID' do
        it_behaves_like 'a show action'
      end
    end
  end
end
