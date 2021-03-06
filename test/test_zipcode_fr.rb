require 'minitest/autorun'
require 'zipcode-fr'
require 'set'

class TestZipCodeFR < MiniTest::Test
  class << self
    def setup
      @loaded ||= ZipCode::DB.for(:fr).load
    end
  end

  def setup
    self.class.setup
  end

  def test_search_by_word_prefix
    results = ZipCode::DB.for(:fr).search(:name, 'PER')
    assert_equal(273, results.count)
  end

  def test_search_by_first_word_prefix
    results = ZipCode::DB.for(:fr).search(:name, 'PERROS')
    assert_equal(4, results.count)
    assert_equal(Set.new(%w[22168 22168 22324 22168]),
                 Set.new(results.map { |e| e[:insee] }))
  end

  def test_search_by_last_word_prefix
    results = ZipCode::DB.for(:fr).search(:name, 'PERNELLE')
    assert_equal(1, results.count)
    assert_equal('50630', results.first[:zip])
  end

  def test_search_by_full_name
    results = ZipCode::DB.for(:fr).search(:name, 'VAGNEY')
    assert_equal(1, results.count)
    assert_equal('88120', results.first[:zip])
  end

  def test_search_by_full_name_with_space
    results = ZipCode::DB.for(:fr).search(:name, 'LA PERNELLE')
    assert_equal(1, results.count)
    assert_equal('50630', results.first[:zip])
  end
end
