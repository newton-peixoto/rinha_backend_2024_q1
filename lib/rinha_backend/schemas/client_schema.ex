defmodule RinhaBackend.ClientSchema do
  use Ecto.Schema

  schema "clientes" do
    field(:nome)
    field(:limite, :integer)
    field(:saldo, :integer)
  end
end
