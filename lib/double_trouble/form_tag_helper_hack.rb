# HAX AHEAD: monkey patching is required to make it work

module ActionView::Helpers::FormTagHelper
  private

  def form_tag_html_with_double_trouble(html_options)
    extra_tags = double_trouble_extra_tags_for_form
    (form_tag_html_without_double_trouble(html_options) + extra_tags).html_safe
  end

  alias_method_chain :form_tag_html, :double_trouble

  def double_trouble_extra_tags_for_form
    (protect_against_double_trouble?) ? content_tag(:div, double_trouble_nonce_tag, :style => "margin:0;padding:0;display:inline") : ""
  end

  def double_trouble_nonce_tag
    tag(:input, :type => "hidden", :name => double_trouble_nonce_param.to_s, :value => double_trouble_form_nonce)
  end
end
