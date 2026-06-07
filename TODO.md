# TODO

- [ ] Add backend request/response logging for `/auth/register` and `/auth/login` to identify source of HTTP 400.
- [ ] Run backend locally and reproduce login to capture failing endpoint + response body.
- [ ] If 400 is from Axum JSON deserialization, update frontend payload keys/types accordingly.
- [ ] If 400 is from SQLx/DB constraint errors, ensure registration handles existing users gracefully (409 instead of 400) and surface message to Flutter.
- [ ] Add Flutter-side display of backend `message` from `_parseError()` (already implemented) and ensure it reaches UI.
- [ ] Re-test login after fix.

