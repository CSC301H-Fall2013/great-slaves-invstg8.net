class Question < ActiveRecord::Base
  has_many :answer #make singular?
  has_many :appended_details  #ignore for now

  belongs_to :asker

  attr_accessible :email, :topic, :phone_number, :body, :created_at, :updated_at, :escalated, :needed_by 
  
  attr_accessor :body, :appended_info, :update_tag

  def escalate_to_admin
    self.update_attributes(:escalated => true)

    InvestigateMailer.escalate_email(self).deliver
  end

  def send_to_researcher(researcher)
    a = Answer.new :answerer => researcher, :question => self
    InvestigateMailer.question_email(a).deliver if a.save
  end

  def should_escalate?
    #All users have answered and all answers were empty
    if answers.where(:answered => true).where('body IS NOT NULL').count == 0
      return true if self.answers.where(:answered => false).count == 0
      return true if Time.now > self.needed_by
    end
    return false
  end

  def SetQuestion(body)
      self.body = body
  end

  def Add_Info(text)
	self.update_tag = true
	self.appended_info = text
  end

  def GetQuestion
	return self.body, self.appended_info
  end 
end
