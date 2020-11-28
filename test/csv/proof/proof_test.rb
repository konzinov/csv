# just to be able to load the right helper because it changed betwween 8505ff0900a478 and now
begin
  require_relative "../helper"
rescue LoadError
  require_relative "../base"
  puts "../helper not found"
end

class ProofTest < Test::Unit::TestCase
  def test_read_positions
    @csv_reader = CsvReader.new('file.csv')
    positions = @csv_reader.read_positions
    puts positions
    # Before commit 8505ff0 this test was passing. But now position stays at the first line.
    assert_equal positions, positions.uniq, "Not unique"
  end

  class CsvReader
    attr_accessor :file_name

    def initialize(file_name)
      @file_name = file_name
    end

    # This method collects positions in the csv file
    def read_positions
      [].tap do |positions|
        reader.each { |pos, _| positions << pos }
      end
    end

    private

    def open
      file = File.expand_path(File.join(File.dirname(__FILE__), file_name))
      CSV.open(file, 'rb', {col_sep: ';', encoding: 'ISO-8859-1'}) do |csv|
        yield csv
      end
    end

    def reader
      return enum_for(:reader) unless block_given?

      open do |io|
        pos = io.tell
        io.each { |row| yield(pos, row); pos = io.tell }
      end
    end
  end
end
