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
    comment = @post.comments.find(params[:comment_id])

    unless comment.user_id == current_user.id || current_user.admin?
      redirect_to feed_post_path(@post), alert: "You can only delete your own comments." and return
    end

    comment.destroy
    redirect_to feed_post_path(@post), notice: "Comment removed."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end
end
