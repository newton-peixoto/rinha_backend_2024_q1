defmodule RinhaBackend.TransactionSchema do
  use Ecto.Schema

  schema "transacoes" do
    field :tipo, Ecto.Enum, values: [:c, :d]
    field(:descricao, :string)
    field(:valor, :integer)
    field(:cliente_id, :integer)
    field(:realizada_em, :naive_datetime)
  end
end
