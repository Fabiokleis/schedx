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

  def parse([], acc), do: acc

  def parse([{k, "*"} | rest], acc), do: parse(rest, [{k, "*"} | acc])

  def parse([{k, i} | rest], acc) do
    case Integer.parse(i, 10) do
      {v, ""} ->
        case k do
          :minute when v >= 0 and v <= 59 -> parse(rest, [{k, v} | acc])
          :hour when v >= 0 and v <= 23 -> parse(rest, [{k, v} | acc])
          :day when v >= 1 and v <= 31 -> parse(rest, [{k, v} | acc])
          :month when v >= 1 and v <= 12 -> parse(rest, [{k, v} | acc])
          :weekday when v >= 0 and v <= 6 -> parse(rest, [{k, v} | acc])
          _ -> :invalid
        end

      _ ->
        :invalid
    end
  end

  def parse(jobstr) do
    [minute, hour, day, month, weekday] = String.split(jobstr, " ")

    parse(
      [
        minute: minute,
        hour: hour,
        day: day,
        month: month,
        weekday: weekday
      ],
      []
    )
  end
end
