module ApplicationHelper
  def page_title
    content_for?(:title) ? yield(:title) : "Fantasy capital"
  end

  def page_class
    "#{controller_name}_#{action_name}".downcase
  end

  def page_id
    "#{controller_name}_#{action_name}".downcase
  end
end

