class InvoicesController < ApplicationController
  include Concerns::ResourceController
  include Concerns::ResourceBelongsToUser
end
