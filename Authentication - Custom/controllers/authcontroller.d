module controllers.authcontroller;

import diamond.controllers;
import diamond.authentication;

import models;

private
{
  bool isAuthenticated(string token)
  {
    // TODO: Validate the token.
    return token == "authtoken";
  }

  string generateAuthToken()
  {
    // TODO: Generate auth token.
    return "authtoken";
  }

  void login(HttpClient client)
  {
    import std.datetime : Clock;
    import core.time : minutes;
    
    const loginTime = 99999;

    client.session.updateEndTime(Clock.currTime() + loginTime.minutes);

    auto token = generateAuthToken();

    client.cookies.create(HttpCookieType.functional, "auth", token, loginTime * 60);
  }

  void logout(HttpClient client)
  {
    client.session.clearValues();
    client.cookies.remove("auth");
  }
}

final class Authenticator : IControllerAuth
{
  public:
  AuthStatus isAuthenticated(HttpClient client)
  {
    return new AuthStatus(
      client,
      .isAuthenticated(client.cookies.get("auth")),
      "Not logged in."
    );
  }

  void authenticationFailed(AuthStatus status)
  {
    auto authCookie = status.client.cookies.getAuthCookie();

    if (!status.authenticated && authCookie && authCookie.length)
    {
      // Invalid auth token. Forced logout.
      logout(status.client);
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
      .login(client);

      success = true;
    }

    return json(AuthResponse(success));
  }

  @HttpDisableAuth @HttpAction(HttpPost) Status logout()
  {
    .logout(client);

    return json(AuthResponse(true));
  }
}
