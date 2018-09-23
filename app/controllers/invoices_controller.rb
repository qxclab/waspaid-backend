class InvoicesController < ApplicationController
  include Concerns::ResourceController
  include Concerns::ResourceBelongsToUser

  private

  def permitted_attributes
    @permitted_attributes ||= attributes.push('value') - %w( id created_at updated_at)
  end
end
