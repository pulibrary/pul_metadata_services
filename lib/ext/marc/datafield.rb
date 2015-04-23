module MARC
  class DataField

    ALPHA = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)

    def format(hsh={})
      codes = hsh.has_key?(:codes) ? hsh[:codes] : ALPHA
      separator = hsh.has_key?(:separator) ? hsh[:separator] : ' '
      exclude_alpha = hsh.has_key?(:exclude_alpha) ? hsh[:exclude_alpha] : []

      exclude_alpha.each { |ex| codes.delete ex }

      subfield_values = []
      self.select { |sf| codes.include? sf.code }.each do |sf|
        subfield_values << sf.value
      end
      subfield_values.join(separator)
    end

    def has_linked_field?
      !self['6'].nil?
    end

  end
end
