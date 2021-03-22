defmodule HnAggregator.Item do
  @moduledoc """
      A struct representation of the Hacker News item.
  """

  @type t :: %HnAggregator.Item{
          id: integer,
          deleted: boolean,
          type: String.t(),
          by: String.t(),
          time: integer,
          text: String.t(),
          dead: boolean,
          parent: integer,
          poll: integer,
          kids: [integer],
          url: String.t(),
          score: integer,
          title: String.t(),
          parts: [integer],
          descendants: integer
        }
  defstruct [
    :id,
    :deleted,
    :type,
    :by,
    :time,
    :text,
    :dead,
    :parent,
    :poll,
    :kids,
    :url,
    :score,
    :title,
    :parts,
    :descendants
  ]
end
