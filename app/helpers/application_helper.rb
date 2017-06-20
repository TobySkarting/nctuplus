module ApplicationHelper

  def user_avatar(name, url, h, w)
    return "<img alt='#{name}' height='#{h}' width='#{w}' src='#{url}'>".html_safe
  end

  def loading_img
    html="<p class='text-center'>#{fa_icon("refresh spin 2x")}</p>"
    return html.html_safe
  end
  def numeric?(string)
    # `!!` converts parsed number to `true`
    !!Kernel.Float(string) 
  rescue TypeError, ArgumentError
    false
  end

  def nctuplus_developer
    current_user && (current_user.role == 0 || current_user.role == 3)
  end
end
