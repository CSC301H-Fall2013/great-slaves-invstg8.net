class AnswersController < ApplicationController
  def new
    @answer = Answer.new
  end

  def show
    if current_user
      @answer = Answer.find params[:id]
    else
       redirect_to root_url
    end
  end

  def edit
    if current_user
      @answer = Answer.find params[:id]
    else
       redirect_to root_url
    end
  end

  def update
    if current_user
      @answer = Answer.find params[:id]
      @answer.body = params[:body]
      @answer.answered = true
      @answer.save
      if @answer.body.nil?
        #Check to see if admin should be notified if all answers
        puts "ESCALATE"
        @answer.question.escalate_to_admin if @answer.question.should_escalate?
      else
        puts "SEND TO JORUNALIST"
        #Email/SMS user who submitted the question
        @answer.send_to_journalist
      end
      render :thank_you
    else
       redirect_to root_url
    end  
  end

  def no_answer
    @answer = Answer.find params[:id]
    @answer.answered = true
    @answer.save
    
    @answer.question.escalate_to_admin if @answer.question.should_escalate?

    render :thank_you
  end
end
