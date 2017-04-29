module ApplicationHelper
  def set_table_partial(collection, partial_path)
    if collection.empty?
      "errors/no_data"
    else
      partial_path
    end
  end
end
