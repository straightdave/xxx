class Tag < ActiveRecord::Base
  # == associations ==
  # refer to all questions belongs to such tag
  has_and_belongs_to_many :questions, join_table: "question_tag",
                                      class_name: "Question",
                                      foreign_key: "tag_id",
                                      association_foreign_key: "question_id"

  # refer to all articles belongs to such tag
  has_and_belongs_to_many :articles, join_table: "article_tag",
                                     class_name: "Article",
                                     foreign_key: "tag_id",
                                     association_foreign_key: "article_id"

  # users who had answered questions/wrote articles under this tag
  has_many :users, through: :expertises
  has_many :expertises

  # == validations ==
  validates :name, length: { maximum: 50, too_long: "名字请勿超过50字符" }
  validates :desc, length: { maximum: 100, too_long: "描述请勿超过100字符" }

  # == helpers ==
  # top used tags for all
  def self.top_used(number)
    Tag.order(used: :desc).take(number)
  end

  # for one tag: top expert users
  def top_experts(number)
    temp_relations = self.expertises.where("expert_score > 0")
                                    .order(expert_score: :desc)

    if number && number > 0
      top_expert = temp_relations.take(number)
    else
      top_expert = temp_relations.all
    end

    expert_ids = []
    top_expert.each do |e|
      expert_ids << e.user_id
    end
    User.find(expert_ids)
  end

  def self.ft_search(keys)
    search_str = keys.join(" ")
    Tag.where("MATCH (name, `desc`) AGAINST ( ? IN NATURAL LANGUAGE MODE )",
              search_str)
  end

  def self.ft_search_name(keys, limit = 10)
    search_str = keys.join(" ")
    Tag.where("MATCH (name) AGAINST ( ? IN NATURAL LANGUAGE MODE )",
              search_str).take(limit)
  end
end
