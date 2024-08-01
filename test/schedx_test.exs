defmodule SchedxTest do
  use ExUnit.Case
  doctest Schedx

  test "test cron parser" do
    assert Cronparser.parse("* * * * 1") != :invalid
    assert Cronparser.parse("30 23 * * 6") != :invalid
    assert Cronparser.parse("60 23 * * 6") == :invalid
    assert Cronparser.parse("59 24 * * 6") == :invalid
    assert Cronparser.parse("a 23 * * 6") == :invalid
    assert Cronparser.parse("0 23 * * 7") == :invalid
    assert Cronparser.parse("0 23 * 13 2") == :invalid
    assert Cronparser.parse("0 23 0 * 6") == :invalid
    assert Cronparser.parse("0 -1 1 * 4") == :invalid
  end
end
