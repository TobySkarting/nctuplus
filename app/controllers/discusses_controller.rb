class DiscussesController < ApplicationController

	layout false, :only =>[:list_by_course]
	before_filter :checkLogin, :only=>[:new_discuss, :new_sub_discuss, :update_discuss, :like]
	
	def like
		@like=DiscussLike.new
		@like.user_id=current_user.id
		@like.like=params[:like]
		case params[:type] 
			when "main"
				@like.discuss_id=params[:discuss_id]
				@discuss=Discuss.find(params[:discuss_id])
				unless @discuss.discuss_likes.select{|l|l.user_id==current_user.id}.empty?
					render :nothing => true, :status => 400, :content_type => 'text/html'
					return
				end
			when "sub"
				@like.sub_discuss_id=params[:discuss_id]
				@discuss=SubDiscuss.find(params[:discuss_id])
				unless @discuss.discuss_likes.select{|l|l.user_id==current_user.id}.empty?
					render :nothing => true, :status => 400, :content_type => 'text/html'
					return
				end
			else 
				return
		end
		@like.save!
		if @like.like
			@discuss.likes+=1
			@discuss.save!
		else
			@discuss.dislikes+=1
			@discuss.save!
		end
		render :nothing => true, :status => 200, :content_type => 'text/html'	
		
	end
	
	def list_by_course
		@ct_id=params[:ct_id].to_i
		@ct=CourseTeachership.find(@ct_id)
		@discusses=Discuss.includes(:sub_discusses, :user, :discuss_likes).where(:course_teachership_id=>@ct_id).order("likes DESC")
		render "show_discussion"
	end
	
	def new_discuss
		title=params[:main_title]
		content=params[:main_content]
		@ct_id=params[:ct_id]
		@discuss=Discuss.new
		@discuss.course_teachership_id=@ct_id
		@discuss.user_id=current_user.id
		@discuss.likes=0
		@discuss.dislikes=0
		@discuss.title=title
		@discuss.content=content
		@discuss.save!
		render "new_discuss_ok"
	end
	
	def new_sub_discuss

		content=params[:sub_content]
		discuss_id=params[:reply_discuss_id]
		@ct_id=params[:ct_id]
		@discuss=SubDiscuss.new
		@discuss.discuss_id=discuss_id
		@discuss.user_id=current_user.id
		@discuss.likes=0
		@discuss.dislikes=0

		@discuss.content=content
		@discuss.save!
		render "new_discuss_ok"
	end
	
	def update_discuss
		
		@discuss=Discuss.find(params[:discuss_id])
		if current_user.id!=@discuss.user_id
			redirect_to :action=> :list_by_course, :ct_id=>params[:ct_id]
			return false;
		end
		@discuss.content=params[:content]
		@discuss.title=params[:title]
		@discuss.save!
		redirect_to :action=> :list_by_course, :ct_id=>params[:ct_id]
	end
	
	
end