module Bigamy

  class MongoBelongsTo < BelongsTo
    def initialize parent, name, options
      super
      me.key foreign_key
    end
  end

  class MongoHasMany < HasMany
  end

  class MongoHasOne < HasOne
  end

  class MongoHasAndBelongsToMany < HasAndBelongsToMany
    def initialize parent, name, options
      super
      me.key as, (options[:unique] ? Set : Array), :default => []
    end

    def add_getter
      mm_get = <<-EOF
        def #{name}
          objects = self.#{as}.blank? ? [] : #{target_klass}.find_all_by_id(self.#{as}.to_a)
          objects
        end
      EOF

      me.class_eval mm_get, __FILE__, __LINE__
    end

    def add_setter
      code = <<-EOF
        def #{name}= objects
          if objects.nil?
            set_value(:#{as}, [])
            return
          end

          raise NewRecordAssignment if objects.any? {|obj| obj.new_record? }
          raise TypeError.new("Should get #{klass}") unless objects.all? {|obj| obj.is_a? #{klass}}

          set_value :#{as},  objects.map(&:#{primary_key})
        end
      EOF
      me.class_eval code, __FILE__, __LINE__
    end
  end
end
