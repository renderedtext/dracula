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
      @banner = if alias_name.nil?
        "--#{name}"
      else
        "-#{alias_name}, --#{name}"
      end

      @banner << " VALUE" unless boolean?

      @banner
    end

  end
end
