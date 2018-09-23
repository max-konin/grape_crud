class ArticleEntity < Grape::Entity
  root :articles, :article
  expose :id, :name
end
