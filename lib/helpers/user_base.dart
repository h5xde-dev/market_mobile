import 'dart:convert';

UserBase fromMap(String str) => UserBase.fromMap(json.decode(str));

String toMap(UserBase data) => json.encode(data.toMap());

class UserBase {
    UserBase({
        this.userId,
        this.name,
        this.lastName,
        this.patronymic,
        this.birthday,
        this.phone,
        this.avatar
    });

    int userId;
    String name;
    String lastName;
    String patronymic;
    String birthday;
    String phone;
    String avatar;

    factory UserBase.fromMap(Map<String, dynamic> json) => UserBase(
        userId: json['userId'],
        name: json['name'],
        lastName: json['last_name'],
        patronymic: json['patronymic'],
        birthday: json['birthday'],
        phone: json['phone'],
        avatar: json['avatar']
    );

    Map<String, dynamic> toMap() => {
        'user_id': userId,
        'name': name,
        'last_name': lastName,
        'patronymic': patronymic,
        'birthday': birthday,
        'phone': phone,
        'avatar': avatar
    };
}
