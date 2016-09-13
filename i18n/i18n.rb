module I18N
  def I18N.set_lang(lang_name)
    lang_name ||= "zh_cn"
    i18n_file = "#{lang_name}.rb"
    require_relative i18n_file
    @lang_dict = I18N.const_get(lang_name.upcase)
  end

  def I18N.ref(txt)
    unless @lang_dict
      I18N.set_lang
    end
    @lang_dict::Ref[txt]
  end
end
