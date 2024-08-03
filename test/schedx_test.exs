defmodule SchedxTest do
  use ExUnit.Case
  doctest Schedx

  test "test cron parser" do
    assert Cronparser.parse("* * * * 1") == [
             minute: :*,
             hour: :*,
             day: :*,
             month: :*,
             weekday: 1
           ]

    assert Cronparser.parse("30 23 * * 6") == [
             minute: 30,
             hour: 23,
             day: :*,
             month: :*,
             weekday: 6
           ]

    assert Cronparser.parse("20 12") == [minute: 20, hour: 12]
    assert Cronparser.parse("30 6,12,18") == [minute: 30, hour: [6, 12, 18]]
    assert Cronparser.parse("30 6 1,15") == [minute: 30, hour: 6, day: [1, 15]]

    assert Cronparser.parse("45 18 * * 0,2,4") == [
             minute: 45,
             hour: 18,
             day: :*,
             month: :*,
             weekday: [0, 2, 4]
           ]

    assert Cronparser.parse("2 9-12 * * 1-5") == [
             minute: 2,
             hour: [9, 12],
             day: :*,
             month: :*,
             weekday: [1, 5]
           ]

    # invalid periodic range
    assert Cronparser.parse("2 9 * * 5-0") == {:weekday, :badcronrange}
    assert Cronparser.parse("2 10-0 * * *") == {:hour, :badcronrange}
    assert Cronparser.parse("2 1,30 * * *") == {:hour, :badcronrange}
    assert Cronparser.parse("2 * * * 1,7") == {:weekday, :badcronrange}

    # invalid literal range
    assert Cronparser.parse("60 23 * * 6") == {:minute, :badcronrange}
    assert Cronparser.parse("59 24 * * 6") == {:hour, :badcronrange}
    assert Cronparser.parse("0 23 * * 7") == {:weekday, :badcronrange}
    assert Cronparser.parse("0 23 * 13 2") == {:month, :badcronrange}
    assert Cronparser.parse("0 23 0 * 6") == {:day, :badcronrange}

    # unsupported syntax
    assert Cronparser.parse("0 -1 1 * 4") == {:hour, :invalid}
    assert Cronparser.parse("1-20 * * * 1,7") == {:minute, :invalid}
    assert Cronparser.parse("a 23 * * 6") == {:minute, :invalid}
  end
end
