module ZipCode
  module FR
    require 'csv'

    module_function

    @indexes ||= {}

    def load
      # TODO: non-optimal, but not overly long either
      index!(:name, reader)
      index!(:zip, reader)
      @loaded = true
    end

    def ready?
      @loaded
    end

    private def data_source
      path = 'vendor/data/code_postaux_v201410.csv'
      File.expand_path(File.join(File.dirname(__FILE__), '..', path))
    end

    private def reader_options
      {
        col_sep: ';',
        encoding: 'ISO-8859-1',
      }
    end

    private def open
      CSV.open(data_source, 'rb', reader_options) do |csv|
        csv.take(1)  # skip header manually to preserve tell()
        yield csv
      end
    end

    private def reader
      Enumerator.new do |y|
        open do |io|
          pos = io.tell
          io.each { |row| y << [pos, clean(row)]; pos = io.tell }
        end
      end
    end

    private def clean(row)
      row_to_h(row_clean(row))
    end

    private def row_clean(row)
      row.map { |e| e.strip.encode('UTF-8') }
    end

    private def row_to_h(row)
      [:insee, :name, :zip, :alt_name].zip(row).to_h
    end

    def index!(name, data, key = nil)
      key ||= name
      index = Hash.new { |h, k| h[k] = [] unless h.frozen? }

      data.each do |pos, record|
        val = record[key]
        val.length.times { |i| index[val[0..i].hash] << pos }
      end

      index.freeze

      @indexes[name] = index
    end

    private def index(name)
      if @indexes.key?(name)
        @indexes[name]
      else
        fail "no index named #{name.inspect}"
      end
    end

    private def read_at(*positions, count: 1)
      Enumerator.new do |y|
        open do |io|
          positions.each do |pos|
            io.seek(pos)
            io.take(count).each { |row| y << clean(row) }
          end
        end
      end
    end

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
