defmodule Chameleon.Hex do
  alias Chameleon.{Rgb, Cmyk, Pantone, Keyword, Hsl}

  @spec to_rgb(charlist) :: list(integer)
  def to_rgb(hex) do
    convert_short_hex_to_long_hex(hex)
    |> String.split("", trim: true)
    |> do_to_rgb
  end

  @spec to_keyword(charlist) :: charlist
  def to_keyword(hex) do
    long_hex = convert_short_hex_to_long_hex(hex)
    keyword_to_hex_map()
    |> Enum.find(fn {_k, v} -> v == String.downcase(long_hex) end)
    |> case do
         {keyword, _hex} -> keyword
         _ -> {:error, "No keyword match could be found for that hex value."}
    end
  end

  @spec to_hsl(charlist) :: list(integer)
  def to_hsl(hex) do
    to_rgb(hex)
    |> Rgb.to_hsl
  end

  @spec to_pantone(charlist) :: charlist
  def to_pantone(hex) do
    long_hex = convert_short_hex_to_long_hex(hex)
    pantone_to_hex_map()
    |> Enum.find(fn {_k, v} -> v == String.upcase(long_hex) end)
    |> case do
         {pantone, _hex} -> pantone
         _ -> {:error, "No keyword match could be found for that hex value."}
    end
  end

  @spec to_cmyk(charlist) :: list(integer)
  def to_cmyk(hex) do
    to_rgb(hex)
    |> Rgb.to_cmyk
  end

  defp do_to_rgb(list) when length(list) == 6 do
    list
    |> Enum.chunk_every(2)
    |> Enum.map(fn(grp) -> Enum.join(grp) |> String.to_integer(16) end)
  end

  defp do_to_rgb(_list) do
    {:error, "A hex value must be provided as 3 or 6 characters."}
  end

  defp keyword_to_hex_map do
    Code.eval_file("lib/chameleon/keyword_to_hex.exs")
    |> Tuple.to_list
    |> Enum.at(0)
  end

  defp pantone_to_hex_map do
    Code.eval_file("lib/chameleon/pantone_to_hex.exs")
    |> Tuple.to_list
    |> Enum.at(0)
  end

  defp convert_short_hex_to_long_hex(hex) do
    case String.length(hex) do
      3 ->
        hex
        |> String.split("", trim: true)
        |> Enum.map(fn(grp) -> String.duplicate(grp, 2) end)
        |> Enum.join()
      _ ->
        hex
    end
  end
end