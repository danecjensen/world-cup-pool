class Admin::FeedPostsController < Admin::BaseController
  before_action :set_post, only: [:approve, :destroy]

  def index
    @pending_posts = Post.pending
                         .includes(:user, media_attachment: :blob)
                         .newest_first
  end

  def approve
    @post.approve!(by: current_user)
    redirect_to admin_feed_posts_path, notice: "Post by #{@post.user.display_name} approved."
  end

  def destroy
    @post.destroy
    redirect_to admin_feed_posts_path, notice: "Post by #{@post.user.display_name} rejected and removed."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end
end
