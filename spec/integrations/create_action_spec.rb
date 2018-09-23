require 'spec_helper'

RSpec.describe GrapeCRUD do
  describe '#add_create_action' do
    let(:response_body) { JSON.parse(last_response.body) }

    def app
      subject
    end

    RSpec.shared_examples 'a create action' do
      before { post '/articles', params }
      context 'when params is valid' do
        let(:params) { { article: { name: 'name' } } }
        it { expect(last_response.status).to eq 201 }
        it 'returns serialized new article' do
          expect(response_body).to eq(
            'article' => { 'id' => 1, 'name' => 'name' }
          )
        end
        it 'creates new articles into the store' do
          expect(Article.count).to eq 1
        end
      end
      context 'when params is invalid' do
        let(:params) { { article: {} } }
        it { expect(last_response.status).to eq 400 }
      end
    end

    context 'with auth' do
      context 'when user can create an article' do
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
                  User.new can_create_article: true
                end
              end

              desc 'creats new article'
              params do
                requires :article, type: Hash do
                  requires :name, type: String
                end
              end
              add_create_action authorize: true
            end
          end
        end
        it_behaves_like 'a create action'
      end
      context 'when user can not create an article' do
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
                  User.new can_create_article: false
                end
              end

              desc 'creats new article'
              params do
                requires :article, type: Hash do
                  requires :name, type: String
                end
              end
              add_create_action authorize: true
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

            desc 'creats new article'
            params do
              requires :article, type: Hash do
                requires :name, type: String
              end
            end
            add_create_action authorize: false
          end
        end
      end
      it_behaves_like 'a create action'
    end
  end
end
