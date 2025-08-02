class DocumentsController < ApplicationController
  before_action :set_document
  before_action :authorize_download!

  def show
    redirect_to rails_blob_path(@document, disposition: params[:disposition])
  end

  private

  def set_document
    @document = ActiveStorage::Blob.find_signed!(params[:signed_id] || params[:signed_blob_id])
  rescue ActiveStorage::FileNotFoundError
    redirect_to root_path, alert: "Document not found"
  end

  def authorize_download!
    # Find the RFQ this document belongs to
    attachment = @document.attachments.first
    return redirect_to root_path, alert: "Document not found" unless attachment

    record = attachment.record

    if record.is_a?(Rfq)
      # Allow download if:
      # - User is the RFQ owner (buyer)
      # - User is a supplier and RFQ is published
      # - User has submitted a quote for this RFQ
      unless record.user == current_user ||
             (current_user.supplier? && record.published?) ||
             record.quotes.exists?(user: current_user)
        redirect_to root_path, alert: "You are not authorized to access this document"
      end
    else
      redirect_to root_path, alert: "Invalid document"
    end
  end
end
