class FeedController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]

  def index
    @posts = Post.approved.includes(:user, :comments, media_attachment: :blob).newest_first
    # So a user can see that their own submission is in the queue.
    @pending_posts = if user_signed_in?
      current_user.posts.pending.includes(:comments, media_attachment: :blob).newest_first
    else
      Post.none
    end
    @post = Post.new
  end

  def show
    @post = Post.includes(:user, { comments: :user }, media_attachment: :blob).find(params[:id])

    if @post.pending? && !can_view_pending?(@post)
      redirect_to feed_path, alert: "That post isn't available." and return
    end

    @comment = Comment.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to feed_path, notice: "Thanks! Your post was submitted and will appear once an admin approves it."
    else
      @posts = Post.approved.includes(:user, :comments, media_attachment: :blob).newest_first
      @pending_posts = current_user.posts.pending.includes(:comments, media_attachment: :blob).newest_first
      flash.now[:alert] = @post.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])

    unless @post.user_id == current_user.id || current_user.admin?
      redirect_to feed_path, alert: "You can only delete your own posts." and return
    end

    @post.destroy
    redirect_to feed_path, notice: "Post removed."
  end

  private

  # A still-pending post is only visible to its author and to admins.
  def can_view_pending?(post)
    user_signed_in? && (post.user_id == current_user.id || current_user.admin?)
  end

  def post_params
    params.require(:post).permit(:caption, :media)
  end
end
