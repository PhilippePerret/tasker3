defmodule TaskerWeb.UserForgotPasswordLive do
  use TaskerWeb, :live_view

  alias Tasker.Comptes

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Vous avez oublié votre mot de passe ?
        <:subtitle>We'll send a password reset link to your inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Mèl" required />
        <:actions>
          <.button phx-disable-with="Envoi..." class="w-full">
            Envoyer les instruction de réinitialisation du mot de passe
          </.button>
        </:actions>
      </.simple_form>
      <p class="text-center text-sm mt-4">
        <.link href={~p"/users/register"}>S’inscrire</.link>
        | <.link href={~p"/users/log_in"}>S’identifier</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Comptes.get_user_by_email(email) do
      Comptes.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "Si votre mèl est dans notre système mais n'a pas encore été confirmé, vous allez recevoir un message avec les instructions très prochainement."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
