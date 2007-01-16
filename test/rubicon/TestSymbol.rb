$: << File.dirname($0) << File.join(File.dirname($0), "..")
require 'rubicon'


class TestSymbol < Rubicon::TestCase

# v---------- test --------------v
  class Fred
    $f1 = :Fred
    def Fred
      $f3 = :Fred
    end
  end
  
  module Test
    Fred = 1
    $f2 = :Fred
  end
  
# ^----------- test ------------^

  Fred.new.Fred

  def test_00sanity
    assert_equal($f1.__id__,$f2.__id__)
    assert_equal($f2.__id__,$f3.__id__)
  end

  @@unique_symbol_count = 0

  def gen_unique_symbol
    @@unique_symbol_count += 1
    "rubicon_unique_symbol_#{@@unique_symbol_count}".intern
  end

  Version.greater_than("1.6.8") do 
    def test_s_all_symbols
      assert_instance_of(Array, Symbol.all_symbols)
      Symbol.all_symbols.each do |sym|
        assert_instance_of(Symbol, sym)
      end
      assert_equal(Symbol.all_symbols, Symbol.all_symbols.uniq)

      symbols1 = Symbol.all_symbols
      s1 = gen_unique_symbol
      s2 = gen_unique_symbol
      symbols2 = Symbol.all_symbols
      assert_bag_equal([s1, s2], symbols2 - symbols1)
    end
  end

  def test_VERY_EQUAL # '==='
    assert_equal(true,  :Fred   === :Fred)
    assert_equal(false, :Fred   === :Barney)
    assert_equal(true,  :Barney === :Barney)

    # don't match any non-Symbol
    assert_equal(false,  :Barney === ":Barney")
    assert_equal(false,  :Barney === "Barney")
    assert_equal(false,  :Barney === Object.new)
  end

  def test_id2name
    assert_equal("Fred",:Fred.id2name)
    assert_equal("Barney",:Barney.id2name)
    assert_equal("wilma",:wilma.id2name)
  end

  def test_inspect
    assert_equal(':hello', 'hello'.intern.inspect)
    if Version > "1.6.8"
      assert_equal(':"hello world"', 'hello world'.intern.inspect)
      assert_equal(':"with \" char"', 'with " char'.intern.inspect)
      assert_equal(':"with \\\\ \" chars"', 'with \ " chars'.intern.inspect)
    else
      # before the :"foobar" syntax existed the following was probably
      # as good as anything else ...
      assert_equal(':hello world', 'hello world'.intern.inspect)
      assert_equal(':with " char', 'with " char'.intern.inspect)
      assert_equal(':with \ " chars', 'with \ " chars'.intern.inspect)
    end
  end

  def test_to_i
    assert_equal($f1.to_i,$f2.to_i)
    assert_equal($f2.to_i,$f3.to_i)
    assert(:wilma.to_i != :Fred.to_i)
    assert(:Barney.to_i != :wilma.to_i)
  end

  def test_to_s
    assert_equal("Fred",:Fred.id2name)
    assert_equal("Barney",:Barney.id2name)
    assert_equal("wilma",:wilma.id2name)
  end

  Version.greater_than("1.6.8") do 
    def test_to_sym
      assert_equal(:Fred, :Fred.to_sym)
      assert_equal(:Barney, :Barney.to_sym)
      assert_equal(:wilma, :wilma.to_sym)
    end
  end

  def test_type
    assert_equal(Symbol, :Fred.class)
    assert_equal(Symbol, :fubar.class)
  end

  def test_taint
    assert_same(:Fred, :Fred.taint)
    assert(! :Fred.tainted?)
  end

  def test_freeze
    assert_same(:Fred, :Fred.freeze)
    assert(! :Fred.frozen?)
  end

  def test_dup
    assert_raise(TypeError) { :Fred.clone }
    assert_raise(TypeError) { :Fred.dup }
  end
end

Rubicon::handleTests(TestSymbol) if $0 == __FILE__
