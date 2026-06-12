class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  def create
    comment = @post.comments.build(user: current_user, body: params.require(:comment)[:body])

    if comment.save
      redirect_to feed_post_path(@post), notice: "Comment added."
    else
      redirect_to feed_post_path(@post), alert: comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    comment = @post.comments.where(user: current_user).find(params[:comment_id])
    comment.destroy
    redirect_to feed_post_path(@post), notice: "Comment removed."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end
end
