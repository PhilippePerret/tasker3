defmodule TaskerWeb.ChantierLive.Index do
  use TaskerWeb, :live_view

  alias Tasker.Taches
  alias Tasker.Taches.Chantier

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :chantiers, Taches.list_chantiers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Modification du Chantier")
    |> assign(:chantier, Taches.get_chantier!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Nouveau Chantier")
    |> assign(:chantier, %Chantier{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Liste des chantiers")
    |> assign(:chantier, nil)
  end

  @impl true
  def handle_info({TaskerWeb.ChantierLive.FormComponent, {:saved, chantier}}, socket) do
    {:noreply, stream_insert(socket, :chantiers, chantier)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    chantier = Taches.get_chantier!(id)
    {:ok, _} = Taches.delete_chantier(chantier)

    {:noreply, stream_delete(socket, :chantiers, chantier)}
  end

end
