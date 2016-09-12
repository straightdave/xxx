module I18N
  def I18N.set_lang(lang_name)
    case lang_name
    when "en_us"
      require_relative "en_us.rb"
      @lang_dict = I18N.const_get("EN_US")
    else
      require_relative "zh_cn.rb"
      @lang_dict = I18N.const_get("ZH_CN")
    end
  end

  def I18N.ref(txt)
    unless @lang_dict
      I18N.set_lang("default")
    end
    @lang_dict::Ref[txt]
  end
end
