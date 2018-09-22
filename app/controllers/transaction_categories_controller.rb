class TransactionCategoriesController < ApplicationController
  include Concerns::ResourceController
  include Concerns::ResourceBelongsToUser
end
