module Bigamy

  class Proxy
    attr_accessor :name, :me, :primary_key, :foreign_key, :klass, :methods_added,
      :options

    def initialize parent, name, options
      self.name = name
      self.me = parent
      self.primary_key = options.delete(:primary_key) || :id
      self.klass = options.delete(:class) || target_klass
      self.methods_added = Set.new
      self.options = options

      serialize_foreign_key
      create_accessors
      serialize_foreign_key
    end

    def foreign_key
      options[:foreign_key] || :"#{name.to_s.singularize}_id"
    end

    def create_accessors
      methods_added << name
      methods_added << "#{name}="

      add_getter
      add_setter
    end

    def add_getter
      raise
    end

    def add_setter
      raise
    end

    def serialize_foreign_key
      target_klass.class_eval <<-EOF
        def #{foreign_key}
          import_id_val read_val(:#{foreign_key})
        end
        EOF
    end

    def divorce_everyone
      methods_added.each {|m| me.send(:undef_method, m) if me.respond_to?(m)}
      self.methods_added = Set.new
    end

    def target_klass
      name.to_s.camelcase.singularize.constantize
    end

    def target_klass_name
      name.to_s.underscore.singularize.gsub('/', '_')
    end

    def root_klass
      me
    end

    def root_klass_name
      me.to_s.underscore.singularize.gsub('/', '_')
    end
  end

  class HasOne < Proxy    
    def foreign_key
      options[:foreign_key] || :"#{root_klass_name}_id"
    end

    def add_getter 
      me.class_eval <<-EOF
        def #{name}
          self.id.nil? ? nil : #{target_klass}.first(:conditions => {:#{foreign_key} => export_id_val(self.id)})
        end
      EOF
    end

    def add_setter
      me.class_eval <<-EOF
        def #{name}= v
          raise NewRecordAssignment.new('Child must be saved') if v.new_record?
          raise NewRecordAssignment.new('Parent must be saved') if self.new_record?
          raise TypeError unless v.is_a? #{klass}

          v.#{foreign_key} = export_id_val(self.id)
          v.save!
        end
      EOF
    end
  end

  class HasMany < Proxy
    def foreign_key
      options[:foreign_key] || :"#{root_klass_name}_id"
    end

    def add_getter 
      me.class_eval <<-EOF
        def #{name}
          self.id.nil? ? nil : #{target_klass}.all(:conditions => {:#{foreign_key} => export_id_val(self.id)})
        end
      EOF
    end

    def add_setter
      me.class_eval <<-EOF
        def #{name}= val
          raise NewRecordAssignment.new('All children must be saved') if val.select(&:new_record?).present?
          raise NewRecordAssignment.new('Parent must be saved') if self.new_record?

          val.each {|v| v.send "#{foreign_key}=", export_id_val(self.id); v.save! }
        end
      EOF
    end
  end

  class BelongsTo < Proxy
    def initialize parent, name, options
      super
    end

    def foreign_key
      options[:foreign_key] || :"#{target_klass_name}_id"
    end

    def add_getter
      code = <<-EOF
        def #{name}
          self.id.blank? ? nil : #{klass}.first(:conditions => {:#{primary_key} => export_id_val(self.id)})
        end
      EOF

      me.class_eval code, __FILE__, __LINE__
    end

    def add_setter
      code = <<-EOF
        def #{name}= val
          raise NewRecordAssignment if val.new_record?
          raise TypeError.new("Should get #{klass}") unless val.is_a? #{klass}

          set_value :#{foreign_key}, val.id
        end
      EOF

      me.class_eval code, __FILE__, __LINE__ 
    end
  end
end
