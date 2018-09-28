require 'spec_helper'

RSpec.describe GrapeCRUD do
  describe '#add_destroy_action' do
    let(:response_body) { JSON.parse(last_response.body) }
    let!(:article) { Article.create name: 'my awesome article' }

    def app
      subject
    end

    RSpec.shared_examples 'a destroy action' do
      before { delete "/articles#{article.id}" }
      context 'when params is valid' do
        it { expect(last_response.status).to eq 204 }
        it 'removes article from the store' do
          expect(Article.count).to eq 0
        end
      end
      context 'when params is invalid' do
        let(:params) { { article: {} } }
        it { expect(last_response.status).to eq 400 }
      end
    end

    context 'with auth' do
      context 'when user can destroy articles' do
        subject do
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
                  User.new can_manage_articles: true
                end
              end

              desc 'destroy an article'
              add_destroy_action authorize: false
            end
          end
        end
        it_behaves_like 'a destroy action'
      end
      context 'when user can not destroy articles' do
        subject do
          Class.new(Grape::API) do
            include GrapeCRUD

            format :json

            rescue_from Pundit::NotAuthorizedError do |_e|
              rack_response(
                '{ "status": 401, "message": "Unauthorized." }',
                401
              )
            end

            resource :articles do
              helpers do
                def model
                  Article
                end

                def current_user
                  User.new can_manage_articles: false
                end
              end

              desc 'destroy an article'
              add_destroy_action authorize: true
            end
          end
        end
        before { post '/articles', article: { name: 'a' } }
        it { expect(last_response.status).to eq 401 }
      end
    end

    context 'without auth' do
      subject do
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

            desc 'destroy an article'
            add_destroy_action authorize: false
          end
        end
      end
      it_behaves_like 'a destroy action'
    end
  end
end
