class Dracula
  class Flag < Struct.new(:name, :params)

    def short_name
      params[:aliases]
    end

    def type
      params[:type] || :string
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

    def banner
      if alias_name.empty?
        "--#{name}"
      else
        "-#{alias_name}, --#{name}"
      end
    end

  end
end
