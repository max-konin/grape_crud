require 'active_model'

class Article
  include ActiveModel::Model

  attr_accessor :name, :text, :id, :private
  cattr_accessor(:repo) { [] }

  validates_presence_of :name

  class << self
    def find(id)
      record = repo.select { |item| item.id.to_s == id.to_s }
                   .first
      raise '404' if record.nil?
      record
    end

    def all
      repo
    end

    def where(options)
      repo.select do |item|
        options.keys.inject(true) { |acc, k| acc && item.try(k) == options[k] }
      end
    end

    def destroy_all
      Article.repo = []
    end

    def create(attrs)
      new(attrs.merge(id: (Article.repo.size + 1))).save
    end

    def count
      Article.repo.size
    end
  end

  def save
    if valid?
      repo << self
      self
    else
      false
    end
  end

  def destroy
    Article.repo.delete self
  end
end
