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
    @user.can_manage_articles
  end

  def destroy?
    @user.can_manage_articles
  end

  def update?
    @user.can_manage_articles
  end
end
