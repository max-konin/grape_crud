class ArticlePolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    !@record.private
  end

  def create?
    @user.can_create_article
  end
end
