defmodule Imageserver.Repo.Migrations.CreateImage do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :name, :string
      add :description, :string
      add :filename, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:images, [:user_id])

  end
end
