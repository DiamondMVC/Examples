module controllers.authcontroller;

import diamond.controllers;
import diamond.authentication;

import models;

private bool isAuthenticatedInExternalSystem(string token)
{
  // TODO: Validate the token in an external system.
  return token == "authtoken";
}

final class Authenticator : IControllerAuth
{
  public:
  AuthStatus isAuthenticated(HttpClient client)
  {
    return new AuthStatus(
      client,
      isAuthenticatedInExternalSystem(client.cookies.getAuthCookie()),
      "Not logged in."
    );
  }

  void authenticationFailed(AuthStatus status)
  {
    auto authCookie = status.client.cookies.getAuthCookie();

    if (!status.authenticated && authCookie && authCookie.length)
    {
      // Cannot be logged in here if not logged into the external system.
      status.client.logout();
    }
  }
}

@HttpAuthentication(Authenticator.stringof) final class AuthController : ApiController
{
  public:
  final:
  this(HttpClient client)
  {
    super(client);
  }

  @HttpDisableAuth @HttpAction(HttpPost) Status login()
  {
    bool success;

    auto auth = client.getModelFromJson!AuthRequest;

    // TODO: Authenticate in the database.
    if (auth.username == "test" && auth.password == "1234")
    {
      long loginTimeInMinutes = 99999;
      auto userRole = getRole("user");

      client.login(loginTimeInMinutes, userRole);
      success = true;
    }

    return json(AuthResponse(success));
  }

  @HttpDisableAuth @HttpAction(HttpPost) Status logout()
  {
    client.logout();

    return json(AuthResponse(true));
  }
}
