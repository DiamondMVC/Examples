module websettings;

import diamond.core.websettings;

private class Settings : WebSettings
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPServerErrorInfo;
  import diamond.http;
  import diamond.authentication;

  private:
  this()
  {
    super();
  }

  public:
  override void onApplicationStart()
  {
    auto guest = addRole("guest");

    auto user = addRole("user");

    setDefaultRole(guest);

    setTokenValidator(&validateToken);
    setTokenInvalidator(&invalidateToken);
    setTokenSetter(&setToken);
  }

  private
  {
    Role validateToken(string token, HttpClient client)
    {
      //TODO: Validate whether the token is valid in the database.

      return token == "authtoken" ? getRole("user") : getRole("guest");
    }

    void invalidateToken(string token, HttpClient client)
    {
      // TODO: Delete from database.
    }

    string setToken(HttpClient client)
    {
      auto token = "authtoken";

      // TODO: Generate token.
      // TODO: Insert token to database.

      return token;
    }
  }

  override bool onBeforeRequest(HttpClient client)
  {
    return true;
  }

  override void onAfterRequest(HttpClient client)
  {
  }

  override void onHttpError(Throwable thrownError, HTTPServerRequest request,
    HTTPServerResponse response, HTTPServerErrorInfo error)
  {
    response.bodyWriter.write(thrownError.toString());
  }

  override void onNotFound(HTTPServerRequest request, HTTPServerResponse response)
  {
    import std.string : format;

    response.bodyWriter.write(format("The path '%s' wasn't found.", request.path));
  }

  override void onStaticFile(HttpClient client)
  {

  }
}

void initializeWebSettings()
{
  webSettings = new Settings;
}
