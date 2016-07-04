require 'zipcode-db'
require 'csv'

module ZipCode
  # TODO: factor index system out
  # rubocop:disable Metrics/ClassLength
  class FR
    def initialize
      @indexes = {}
      @loaded = false
    end

    def load
      # TODO: non-optimal, but not overly long either
      return true if ready?
      index!(:name, reader, [:word_prefix, :match])
      index!(:zip, reader, :prefix)
      @loaded = true
    end

    def ready?
      @loaded
    end

    def data_source
      path = 'vendor/data/code_postaux_v201410.csv'
      File.expand_path(File.join(File.dirname(__FILE__), '..', path))
    end
    private :data_source

    def reader_options
      {
        col_sep: ';',
        encoding: 'ISO-8859-1',
      }
    end
    private :reader_options

    def open
      CSV.open(data_source, 'rb', reader_options) do |csv|
        csv.take(1)  # skip header manually to preserve tell()
        yield csv
      end
    end
    private :open

    def reader
      return enum_for(:reader) unless block_given?

      open do |io|
        pos = io.tell
        io.each { |row| yield(pos, clean(row)); pos = io.tell }
      end
    end
    private :reader

    def clean(row)
      row_to_h(row_clean(row))
    end
    private :clean

    def row_clean(row)
      row.map { |e| e.strip.encode('UTF-8') }
    end
    private :row_clean

    def row_to_h(row)
      [:insee, :name, :zip, :alt_name].zip(row).to_h
    end
    private :row_to_h

    def index!(name, data, modes = nil, key: nil)
      key ||= name
      index = Hash.new { |h, k| h[k] = [] unless h.frozen? }

      modes = [modes] unless modes.is_a?(Enumerable)
      modes.each do |mode|
        data.each(&appender(index, key, mode))
      end

      index.each { |_, v| v.uniq! }
      index.freeze

      @indexes[name] = index
    end

    # TODO: create an appender registry
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def appender(idx, key, mode)
      case mode
      when :prefix
        -> (pos, record) { append_prefixes(idx, pos, record[key]) }
      when :infix
        -> (pos, record) { append_infixes(idx, pos, record[key]) }
      when :word
        -> (pos, record) { append_words(idx, pos, record[key]) }
      when :word_prefix
        -> (pos, record) { append_word_prefixes(idx, pos, record[key]) }
      else
        -> (pos, record) { append_match(idx, pos, record[key]) }
      end
    end
    private :appender

    def append_match(idx, pos, val)
      idx[val.hash] << pos
    end
    private :append_match

    def append_words(idx, pos, val)
      each_word(val) { |w| idx[w.hash] << pos }
    end
    private :append_words

    def append_word_prefixes(idx, pos, val)
      each_word(val) do |word|
        each_prefix(word) { |prefix| idx[prefix.hash] << pos }
      end
    end
    private :append_word_prefixes

    def append_prefixes(idx, pos, val, min_size: 1)
      each_prefix(val, min_size: min_size) { |prefix| idx[prefix.hash] << pos }
    end
    private :append_prefixes

    def each_word(val, &block)
      val.split.each(&block)
    end
    private :each_word

    def each_prefix(val, min_size: 1)
      min_size.upto(val.length) { |i| yield val[0...i] }
    end
    private :each_prefix

    def each_suffix(val, min_size: 1)
      min_size.upto(val.length) { |i| yield val[-i..-1] }
    end
    private :each_suffix

    def append_infixes(idx, pos, val, min_size: 1)
      each_prefix(val, min_size: min_size) do |prefix|
        each_suffix(prefix, min_size: min_size) do |infix|
          idx[infix.hash] << pos
        end
      end
    end
    private :append_infixes

    def index(name)
      if @indexes.key?(name)
        @indexes[name]
      else
        fail "no index named #{name.inspect}"
      end
    end
    private :index

    def memsize_of_index(name)
      require 'objspace'
      ObjectSpace.memsize_of(@indexes[name]) +
        @indexes[name].reduce(0) { |a, (_, v)| a + ObjectSpace.memsize_of(v) }
    end

    def read_at(*positions, count: 1)
      return enum_for(:read_at, *positions, count: count) unless block_given?

      open do |io|
        positions.each do |pos|
          io.seek(pos)
          io.take(count).each { |row| yield clean(row) }
        end
      end
    end
    private :read_at

    def search(name, str, case_insensitive: true)
      str = str.upcase if case_insensitive
      read_at(*index(name)[str.hash])
    end

    def complete(name, str, key = nil)
      key ||= name
      search(name, str).map { |e| e[key] }
    end
  end
end

ZipCode::DB.register(:fr, ZipCode::FR.new)
