// Copyright (c) {{year}}, {{author}}. All rights reserved. Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

import '../__projectName__.dart';
import '../model/user.dart';

class RegisterController extends QueryController<User> {
  RegisterController(this.authServer);

  AuthServer authServer;

  @httpPost
  Future<Response> createUser() async {
    if (query.values.username == null || query.values.password == null) {
      return new Response.badRequest(
          body: {"error": "username and password required."});
    }

    var salt = AuthUtility.generateRandomSalt();
    var hashedPassword = authServer.hashPassword(query.values.password, salt);

    query.values.hashedPassword = hashedPassword;
    query.values.salt = salt;
    query.values.email = query.values.username;

    var u = await query.insert();
    var token = await authServer.authenticate(
        u.username,
        query.values.password,
        request.authorization.credentials.username,
        request.authorization.credentials.password);

    return AuthController.tokenResponse(token);
  }
}
