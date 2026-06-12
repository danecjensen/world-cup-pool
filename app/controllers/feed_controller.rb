class FeedController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]

  def index
    @posts = Post.includes(:user, :comments, media_attachment: :blob).newest_first
    @post = Post.new
  end

  def show
    @post = Post.includes(:user, { comments: :user }, media_attachment: :blob).find(params[:id])
    @comment = Comment.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to feed_path, notice: "Your post was shared!"
    else
      @posts = Post.includes(:user, :comments, media_attachment: :blob).newest_first
      flash.now[:alert] = @post.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    redirect_to feed_path, notice: "Your post was removed."
  end

  private

  def post_params
    params.require(:post).permit(:caption, :media)
  end
end
