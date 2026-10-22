
module ApplicationHelper
  def naira(kobo)
    Naira.format(kobo)
  end

  def phone_display(phone)
    PhoneNumber.display(phone)
  end

  def call_link(phone, text = "Call", **options)
    link_to text, "tel:#{phone}", **options
  end

  def whatsapp_link(phone, text = "WhatsApp", **options)
    link_to text, "https://wa.me/#{PhoneNumber.whatsapp_digits(phone)}", target: "_blank", rel: "noopener", **options
  end

  def nav_link(text, path)
    active = request.path == path || (path != root_path && request.path.start_with?(path))
    link_to text, path, class: [ "rounded-md px-3 py-1.5 text-sm font-medium",
                                 active ? "bg-emerald-50 text-emerald-800" : "text-gray-600 hover:text-gray-900" ],
                        aria: { current: (active ? "page" : nil) }
  end
end
