module PulMetadataServices
  class BibRecord

    def initialize(source)
      @source = source
    end

    def source
      @source
    end

    def full_source
      @source
    end

    def attributes
      {
        title: title,
        sort_title: sort_title,
        creator: creator,
        date_created: date,
        publisher: publisher
      }
    end

    def abstract
      formatted_fields_as_array('520')
    end

    def alternative_titles
      alt_titles = []
      alt_title_field_tags.each do |tag|
        data.fields(tag).each do |field| # some of these tags are repeatable
          exclude_subfields = tag == '246' ? ['i'] : []
          alt_titles << format_datafield(field, exclude_alpha: exclude_subfields)
          if has_linked_field?(field)
            field = get_linked_field(field)
            alt_titles << format_datafield(field, exclude_alpha: exclude_subfields)
          end
        end
      end
      alt_titles
    end

    def audience
      formatted_fields_as_array('521')
    end

    def citation
      formatted_fields_as_array('524')
    end

    def contributors
      fields = []
      contributors = []
      if creator.empty? && record.has_any_7xx_without_t?
        fields.push *record.fields(['100','110','111'])
        fields.push *record.fields(['700', '710', '711']).select { |df| !df['t'] }
        # By getting all of the fields first and then formatting them we keep
        # the linked field values adjacent to the romanized values. It's a small
        # thing, but may be useful.
        fields.each do |field|
          contributors << format_datafield(field)
          if has_linked_field?(field)
            contributors << format_datafield(get_linked_field(field))
          end
        end
      end
      contributors
    end

    def creator
      creator = []
      if has_1xx? and !has_any_7xx_without_t?
        field = data.fields(['100','110','111'])[0]
        creator << format_datafield(field)
        if has_linked_field?(field)
          creator << format_datafield(get_linked_field(field))
        end
      end
      creator
    end

    def date
      date_from_008
    end

    def description
      formatted_fields_as_array(['500','501','502','504','507','508',
        '511','510','513','514','515','516','518','522','525','526','530',
        '533','534','535','536','538','542','544','545','546','547','550',
        '552','555','556','562','563','565','567','580','581','583','584',
        '585','586','588','590'])
    end

    def extent
      formatted_fields_as_array('300')
    end

    def parts
      parts = []
      fields = []
      data.fields(['700','710','711','730','740']).each do |field|
        if ['700','710','711'].include? field.tag and field['t']
          fields << field
        elsif field.tag == '740' && field.indicator1 == '2'
          fields << field
        elsif field.tag == '730'
          fields << field
        end
      end
      fields.each do |f|
        parts << format_datafield(f)
        if has_linked_field?(f)
          parts << format_datafield(get_linked_field(f))
        end
      end
      parts
    end

    def language_codes
      codes = []
      from_fixed = data['008'].value[35,3]
      codes << from_fixed if !['   ', 'mul'].include? from_fixed

      data.fields('041').each do |df|
        df.select { |sf|
          ['a','d','e','g'].include? sf.code
        }.map { |sf|
          sf.value
        }.each do |c|
          if c.length == 3
            codes << c
          elsif c.length % 3 ==0
            codes.push *c.scan(/.{3}/)
          end
        end
      end
      codes.uniq
    end

    def provenance
      formatted_fields_as_array(['541','561'])
    end

    def publisher
      formatted_fields_as_array(['260','264'], codes: ['b'])
    end

    def rights
      formatted_fields_as_array(['506','540'])
    end

    def sort_title
      title(false)[0]
    end

    def series
      formatted_fields_as_array(['440','490','800','810','811','830'])
    end

    def title(include_initial_article=true)
      title_tag = determine_primary_title_field
      ti_field = data.fields(title_tag)[0]

      titles = []

      if title_tag == '245'
        ti = format_datafield(ti_field).split(' / ')[0]
        if !include_initial_article
          to_chop = data['245'].indicator2.to_i
          ti = ti[to_chop, ti.length-to_chop]
        end

        titles << ti

        if has_linked_field?(ti_field)
          linked_field = get_linked_field(ti_field)
          vern_ti = format_datafield(linked_field).split(' / ')[0]
          if !include_initial_article
            to_chop = linked_field.indicator2.to_i
            vern_ti = vern_ti[to_chop, ti.length-to_chop]
          end
          titles << vern_ti
        end

      else
        # TODO: exclude 'i' when 246
        titles << format_datafield(ti_field)
        if has_linked_field?(ti_field)
          titles << format_datafield(get_linked_field(ti_field))
        end
      end
      titles
    end

    def subjects
      # Broken: name puctuation won't come out correctly
      formatted_fields_as_array(['600','610','611','630','648','650', '651',
        '653','654','655','656','657','658','662','690'], separator: '--')
    end

    # We squash together 505s with ' ; '
    def contents
      entry_sep = ' ; '
      contents = []
      data.fields('505').each do |f|

        entry = format_datafield(f)
        if has_linked_field?(f)
          entry += " = "
          entry += format_datafield(get_linked_field(f))
        end
        contents << entry
      end
      contents.join entry_sep
    end


    def formatted_fields_as_array(fields, opts={})
      vals = []

      data.fields(fields).each do |field|
        val = format_datafield(field, opts)

        vals << val if val != ""

        if has_linked_field?(field)
          linked_field = get_linked_field(field)
          val = format_datafield(linked_field, opts)
          vals << val if val != ""
        end

      end
      vals
    end

    def format_datafield(datafield, hsh={})
      codes = hsh.fetch(:codes, ALPHA)
      separator = hsh.fetch(:separator, ' ')
      exclude_alpha = hsh.fetch(:exclude_alpha, [])

      exclude_alpha.each { |ex| codes.delete ex }

      subfield_values = []
      datafield.select { |sf| codes.include? sf.code }.each do |sf|
        subfield_values << sf.value
      end
      subfield_values.join(separator)
    end

    private

    BIB_LEADER06_TYPES = %w(a c d e f g i j k m o p r t)
    TITLE_FIELDS_BY_PREF = %w(245 240 130 246 222 210 242 243 247)
    ALPHA = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)

    def data
      @data ||= reader.select { |r| BIB_LEADER06_TYPES.include?(r.leader[6]) }[0]
    end

    def reader
      @reader ||= MARC::XMLReader.new(StringIO.new(source))
    end

    def has_1xx?
      data.tags.any? { |t| ['100','110','111'].include? t }
    end

    def has_any_7xx_without_t?
      data.fields(['700', '710', '711']).select { |df| !df['t'] } != []
    end

    def get_linked_field(src_field)
      if src_field['6']
        idx = src_field['6'].split('-')[1].split('/')[0].to_i - 1
        data.select { |df| df.tag == '880' }[idx]
      end
    end

    def date_from_008
      if data['008']
        d = data['008'].value[7,4]
        d = d.gsub 'u', '0' unless d == 'uuuu'
        d = d.gsub ' ', '0' unless d == '    '
        d if d =~ /^[0-9]{4}$/
      end
    end

    # def date_from_008
    #   d = data['008'].value[7,4].gsub 'u', '0'
    #   d if d =~ /^[0-9]{4}$/
    # end

    def determine_primary_title_field
      (TITLE_FIELDS_BY_PREF & data.tags)[0]
    end

    def alt_title_field_tags
      other_title_fields = *TITLE_FIELDS_BY_PREF
      while !other_title_fields.empty? && !found_title_tag ||=false
        # the first one we find will be the title, the rest we want
        found_title_tag = data.tags.include? other_title_fields.shift
      end
      other_title_fields
    end

    def has_linked_field?(datafield)
      !datafield['6'].nil?
    end

  end
end
