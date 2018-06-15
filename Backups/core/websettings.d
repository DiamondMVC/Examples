module websettings;

import diamond.core.websettings;

private class Settings : WebSettings
{
  import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPServerErrorInfo;
  import diamond.http;
  import diamond.security;

  private:
  this()
  {
    super();
  }

  public:
  override void onApplicationStart()
  {
    // Backup every 24 hour.
    auto fileBackup = new FileBackupService(60000 * 24);

    fileBackup.addPath(BackupPath("files", "backup"));

    addBackupService(fileBackup);
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
