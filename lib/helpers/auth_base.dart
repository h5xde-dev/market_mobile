import 'dart:convert';

AuthBase fromMap(String str) => AuthBase.fromMap(json.decode(str));

String toMap(AuthBase data) => json.encode(data.toMap());

class AuthBase {
    AuthBase({
        this.token,
    });

    String token;

    factory AuthBase.fromMap(Map<String, dynamic> json) => AuthBase(
        token: json["token"],
    );

    Map<String, dynamic> toMap() => {
        "token": token,
    };
}
