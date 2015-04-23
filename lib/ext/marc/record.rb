module MARC

  class Record

    BIB_LEADER06_TYPES = %w(a c d e f g i j k m o p r t)
    TITLE_FIELDS_BY_PREF = %w(245 240 130 246 222 210 242 243 247)
    # Shamelessly lifted from SolrMARC, with a few changes; no doubt there will
    # be more.
    THREE_OR_FOUR_DIGITS = /^(20|19|18|17|16|15|14|13|12|11|10|9|8|7|6|5|4|3|2|1)(\d{2})\.?$/
    FOUR_DIGIT_PATTERN_BRACES = /^\[([12]\d{3})\??\]\.?$/
    FOUR_DIGIT_PATTERN_ONE_BRACE = /^\[(20|19|18|17|16|15|14|13|12|11|10)(\d{2})/
    FOUR_DIGIT_PATTERN_OTHER_1 = /^l(\d{3})/
    FOUR_DIGIT_PATTERN_OTHER_2 = /^\[(20|19|18|17|16|15|14|13|12|11|10)\](\d{2})/
    FOUR_DIGIT_PATTERN_OTHER_3 = /^\[?(20|19|18|17|16|15|14|13|12|11|10)(\d)[^\d]\]?/
    FOUR_DIGIT_PATTERN_OTHER_4 = /i\.e\.\,? (20|19|18|17|16|15|14|13|12|11|10)(\d{2})/
    FOUR_DIGIT_PATTERN_OTHER_5 = /^\[?(\d{2})\-\-\??\]?/
    BC_DATE_PATTERN = /[0-9]+ [Bb]\.?[Cc]\.?/

    def formatted_fields_as_array(fields, opts={})
      vals = []

      self.fields(fields).each do |field|
        val = field.format(opts)

        vals << val if val != ""

        if field.has_linked_field?
          linked_field = self.get_linked_field(field)
          # val = codes.nil? ? linked_field.format : linked_field.format(codes: codes)
          val = linked_field.format(opts)
          vals << val if val != ""
        end

      end
      vals
    end

    def abstract
      formatted_fields_as_array('520')
    end

    def alternative_titles
      alt_titles = []
      alt_title_field_tags.each do |tag|
        self.fields(tag).each do |field| # some of these tags are repeatable
          exclude_subfields = tag == '246' ? ['i'] : []
          alt_titles << field.format(exclude_alpha: exclude_subfields)
          if field.has_linked_field?
            alt_titles << get_linked_field(field).format(exclude_alpha: exclude_subfields)
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
          contributors << field.format
          if field.has_linked_field?
            contributors << get_linked_field(field).format
          end
        end
      end
      contributors
    end

    def creator
      creator = []
      if has_1xx? and !has_any_7xx_without_t?
        field = self.fields(['100','110','111'])[0]
        creator << field.format
        if field.has_linked_field?
          creator << get_linked_field(field).format
        end
      end
      creator
    end

    def date
      best_date
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
      self.fields(['700','710','711','730','740']).each do |field|
        if ['700','710','711'].include? field.tag and field['t']
          fields << field
        elsif field.tag == '740' && field.indicator1 == '2'
          fields << field
        elsif field.tag == '730'
          fields << field
        end
      end
      fields.each do |f|
        parts << f.format
        if f.has_linked_field?
          parts << record.get_linked_field(f).format
        end
      end
      parts
    end

    def language_codes
      codes = []
      from_fixed = self['008'].value[35,3]
      codes << from_fixed if !['   ', 'mul'].include? from_fixed

      self.fields('041').each do |df|
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
      formatted_fields_as_array('260', codes: ['b'])
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
      ti_field = self.fields(title_tag)[0]

      titles = []

      if title_tag == '245'
        ti = ti_field.format.split(' / ')[0]
        if !include_initial_article
          chop = self['245'].indicator2.to_i
          ti = ti[chop, ti.length-chop]
        end

        titles << ti

        if ti_field.has_linked_field?
          linked_field = get_linked_field(ti_field)
          vern_ti = linked_field.format.split(' / ')[0]
          if !include_initial_article
            chop = linked_field.indicator2.to_i
            vern_ti = vern_ti[chop,ti.length-chop]
          end
          titles << vern_ti
        end

      else
        # TODO: exclude 'i' when 246
        titles << ti_field.format
        if ti_field.has_linked_field?
          titles <<get_linked_field(ti_field).format
        end
      end
      titles
    end

    def subjects
      formatted_fields_as_array(['600','610','611','630','648','650', '651',
        '653','654','655','656','657','658','662','690'], separator: '--')
    end

    # We squash together 505s with ' ; '
    def contents
      entry_sep = ' ; '
      contents = []
      self.fields('505').each do |f|
        entry = f.format
        if f.has_linked_field?
          entry += " = "
          entry += get_linked_field(f).format
        end
        contents << entry
      end
      contents.join entry_sep
    end


    private
    def has_1xx?
      self.tags.any? { |t| ['100','110','111'].include? t }
    end

    def has_any_7xx_without_t?
      self.fields(['700', '710', '711']).select { |df| !df['t'] } != []
    end

    def get_linked_field(src_field)
      if src_field['6']
        idx = src_field['6'].split('-')[1].split('/')[0].to_i - 1
        self.select { |df| df.tag == '880' }[idx]
      end
    end

    def best_date
      date = nil
      if self['260']['c']
        field_260c = self['260']['c']
        case field_260c
          when THREE_OR_FOUR_DIGITS
            date = "#{$1}#{$2}"
          when FOUR_DIGIT_PATTERN_BRACES
            date = $1
          when FOUR_DIGIT_PATTERN_ONE_BRACE
            date = $1
          when FOUR_DIGIT_PATTERN_OTHER_1
            date = "1#{$1}"
          when FOUR_DIGIT_PATTERN_OTHER_2
            date = "#{$1}#{$2}"
          when FOUR_DIGIT_PATTERN_OTHER_3
            date = "#{$1}#{$2}0"
          when FOUR_DIGIT_PATTERN_OTHER_4
            date = "#{$1}#{$2}"
          when FOUR_DIGIT_PATTERN_OTHER_5
            date = "#{$1}00"
          when BC_DATE_PATTERN
            date = nil
        end
      end
      date ||= self.date_from_008
    end

    def date_from_008
      d = self['008'].value[7,4].gsub 'u', '0'
      d if d =~ /^[0-9]{4}$/
    end

    def determine_primary_title_field
      (TITLE_FIELDS_BY_PREF & self.tags)[0]
    end

    def alt_title_field_tags
      other_title_fields = *TITLE_FIELDS_BY_PREF
      while !other_title_fields.empty? && !found_title_tag ||=false
        # the first one we find will be the title, the rest we want
        found_title_tag = self.tags.include? other_title_fields.shift
      end
      other_title_fields
    end


    def self.strip_brackets(date)
      date.gsub(/[\[\]]/, '')
    end

  end

end
