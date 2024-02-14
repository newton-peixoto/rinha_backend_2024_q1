defmodule RinhaBackendWeb.Controllers.Transaction.TransactionRequest do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:valor, :tipo, :descricao]

  embedded_schema do
    field :tipo, Ecto.Enum, values: [:c, :d]
    field :valor, :integer
    field :descricao, :string
  end

  defp changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:descricao, max: 10, min: 1)
  end

  def validate(params) do
    case changeset(params) do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}

      %Ecto.Changeset{valid?: true, changes: changes} ->
        {:ok, changes}
    end
  end

end
