class Faq < ActiveRecord::Base
  belongs_to :live_show

  validates_presence_of :question, :answer
end