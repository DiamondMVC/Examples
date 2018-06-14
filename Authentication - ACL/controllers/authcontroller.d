module controllers.authcontroller;

import diamond.controllers;
import diamond.authentication;

import models;

final class AuthController : ApiController
{
  public:
  final:
  this(HttpClient client)
  {
    super(client);
  }

  @HttpAction(HttpPost) Status login()
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

  @HttpAction(HttpPost) Status logout()
  {
    client.logout();

    return json(AuthResponse(true));
  }
}
