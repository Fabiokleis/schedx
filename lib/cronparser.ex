defmodule Cronparser do
  # cron wiki 
  # https://en.wikipedia.org/wiki/Cron
  # ┌───────────── minute (0–59)
  # │ ┌───────────── hour (0–23)
  # │ │ ┌───────────── day of the month (1–31)
  # │ │ │ ┌───────────── month (1–12)
  # │ │ │ │ ┌───────────── day of the week (0–6) (Sunday to Saturday;
  # │ │ │ │ │                                   7 is also Sunday on some systems)
  # │ │ │ │ │
  # │ │ │ │ │
  # * * * * * <command to execute>

  def match_range(key, value) do
    case key do
      :minute when value >= 0 and value <= 59 -> value
      :hour when value >= 0 and value <= 23 -> value
      :day when value >= 1 and value <= 31 -> value
      :month when value >= 1 and value <= 12 -> value
      :weekday when value >= 0 and value <= 6 -> value
      _ -> :badcronrange
    end
  end

  # TODO:
  # - add periodic parsing for minutes;
  def parse_token(key, token) do
    cond do
      String.match?(token, ~r/^\d{1,2}$/) ->
        match_range(key, String.to_integer(token))

      String.match?(token, ~r/^(\d{1,2}(,\d{1,2}){0,30})$/) ->
        token
        |> String.split(",")
        |> Enum.uniq()
        |> Enum.map(&String.to_integer/1)

      key != :minute and String.match?(token, ~r/^\d{1,2}-\d{1,2}$/) ->
        case String.split(token, "-") |> Enum.map(&String.to_integer/1) do
          [a, a] -> match_range(key, a)
          [a, b] when a < b -> Enum.to_list(a..b)
          _ -> :badcronrange
        end

      true ->
        :invalid
    end
  end

  def parse([], acc), do: Enum.reverse(acc)

  def parse([{k, "*"} | rest], acc), do: parse(rest, [{k, :*} | acc])

  def parse([{key, token} | rest], acc) do
    case parse_token(key, token) do
      :* ->
        parse(rest, [{key, :*} | acc])

      value when is_number(value) ->
        parse(rest, [{key, value} | acc])

      value when is_list(value) ->
        case Enum.any?(value, fn v -> match_range(key, v) == :badcronrange end) do
          false -> parse(rest, [{key, value} | acc])
          true -> {key, :badcronrange}
        end

      reason ->
        {key, reason}
    end
  end

  def parse(jobstr) do
    a =
      [:minute, :hour, :day, :month, :weekday]
      |> Enum.zip(String.split(jobstr, " "))
      |> parse([])

    IO.puts("#{inspect(a)}")

    a
  end
end
