defmodule TaskerWeb.ChantierLive.Show do
  use TaskerWeb, :live_view

  alias Tasker.Taches

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:chantier, Taches.get_chantier!(id))}
  end

  defp page_title(:show), do: "Show Chantier"
  defp page_title(:edit), do: "Edit Chantier"
end
