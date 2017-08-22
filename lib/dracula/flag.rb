class Dracula
  class Flag < Struct.new(:name, :params)

    def type
      params[:type] || :string
    end

    def required?
      params[:required] == true
    end

    def boolean?
      type == :boolean
    end

    def has_default_value?
      params.has_key?(:default) || boolean?
    end

    def default_value
      if boolean?
        params.key?(:default) ? params[:default] : false
      else
        params[:default]
      end
    end

    def alias_name
      params[:alias]
    end

    alias_method :short_name, :alias_name

    def banner
      if short_name_banner
        "#{short_name_banner}, #{long_name_banner}"
      else
        long_name_banner
      end
    end

    def short_name_banner
      return nil if short_name.nil?

      if boolean?
        "-#{short_name}"
      else
        "-#{short_name} #{name.upcase}"
      end
    end

    def long_name_banner
      if boolean?
        "--#{name}"
      else
        "--#{name} #{name.upcase}"
      end
    end

  end
end
