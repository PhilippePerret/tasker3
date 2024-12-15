defmodule TaskerWeb.Router do
  use TaskerWeb, :router

  import TaskerWeb.UserAuth
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/work", TaskerWeb do
    pipe_through :browser
    
    live "/", WorkLive, :current
  end

  scope "/taches", TaskerWeb do
    pipe_through :browser

    live "/", TacheLive.Liste, :liste
    live "/list", TacheLive.Liste, :liste
    live "/new", TacheLive.Liste, :new
    live "/:id/edit", TacheLive.Liste, :edit

    live "/:id", TacheLive.Item, :show
    # live "/:id/show/edit", TacheLive.Item, :edit
    live "/:id/delete", TacheLive.Item, :delete

    # get "list", TachesController, :list
    # live "/new", Tache
  end

  scope "/chantiers", TaskerWeb do
    pipe_through :browser

    live "/", ChantierLive.Index, :index
    live "/new", ChantierLive.Index, :new
    live "/:id/edit", ChantierLive.Index, :edit

    live "/:id", ChantierLive.Show, :show
    live "/:id/show/edit", ChantierLive.Show, :edit
  end

  scope "/users", TaskerWeb do
    pipe_through :browser
    
    get "/", UsersController, :liste
    # get "/:id", UsersController, :show
  end

  scope "/calc", TaskerWeb do
    pipe_through :browser

    live "/", Monform
  end

  scope "/", TaskerWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/hello", Hello
  end

  # Other scopes may use custom stacks.
  # scope "/api", TaskerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:Tasker, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TaskerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TaskerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TaskerWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TaskerWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TaskerWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", TaskerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TaskerWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
