module Bigamy

  class ARBelongsTo < BelongsTo
  end

  class ARHasOne < HasOne
    def initialize parent, name, options
      super
      target_klass.key foreign_key
    end
  end

  class ARHasMany < HasMany
    def initialize parent, name, options
      super
      target_klass.key foreign_key
    end
  end

  class ARHasAndBelongsToMany < HasAndBelongsToMany
    def foreign_key
      options[:foreign_key] || :"#{root_klass_name}_ids"
    end

    def add_getter
      ar_get = <<-EOF
        def #{name}
          #{target_klass}.where(:#{foreign_key} => #{primary_key})
        end
      EOF

      me.class_eval ar_get, __FILE__, __LINE__
    end

    def add_setter
      code = <<-EOF
        def #{name}= objects
          raise "Not Yet Implemented"
        end
      EOF
      me.class_eval code, __FILE__, __LINE__
    end
  end
end
