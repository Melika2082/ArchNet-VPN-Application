import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  late Future<Map<String, dynamic>> userInfoFuture;

  final client = http.Client();

  @override
  void initState() {
    super.initState();
    userInfoFuture = getUserInfo(context);
  }

  Future<Map<String, dynamic>> getUserInfo(BuildContext context) async {
    try {
      var box = await Hive.openBox('userBox');
      String email = box.get('email') ?? '';
      String password = box.get('password') ?? '';
      if (email.isNotEmpty && password.isNotEmpty) {
        final res = await client.post(
          Uri.parse('https://hub.archnets.com/api/v2/client/token'),
          headers: <String, String>{
            'XMPus-API-Token': '15dde8524a8b998932564e11b3bd5fe5',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'passwd': password,
          }),
        );

        if (res.statusCode == 200) {
          final token = jsonDecode(res.body)['data']['token'];

          final userInfoRes = await client.post(
            Uri.parse('https://hub.archnets.com/api/v2/client/stats'),
            headers: <String, String>{
              'XMPus-API-Token': '15dde8524a8b998932564e11b3bd5fe5',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'token': token,
            }),
          );

          if (userInfoRes.statusCode == 200) {
            return jsonDecode(userInfoRes.body)['info'];
          } else {
            throw Exception('اطلاعات کاربر بارگیری نشد');
          }
        } else {
          throw Exception('توکن دریافت نشد');
        }
      } else {
        throw Exception('User is not logged in');
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (snapshot.hasError) {
          return Text(
            'خطا : ${snapshot.error}',
            style: const TextStyle(
              color: Colors.white,
            ),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final userInfo = snapshot.data;
          List<Map<String, dynamic>> userInformation = [
            {
              'title': 'نام کاربری',
              'value': userInfo?['username'],
            },
            {
              'title': 'ایمیل',
              'value': userInfo?['email'],
            },
            {
              'title': 'موجودی',
              'value': userInfo?['money'],
            },
            {
              'title': 'کمیسیون',
              'value': userInfo?['commission'],
            },
            {
              'title': 'محدودیت اتصال به ازای هر دستگاه',
              'value': userInfo?['iplimit'],
            },
            {
              'title': 'IP آنلاین',
              'value': userInfo?['onlineip'],
            },
            {
              'title': 'محدودیت سرعت',
              'value': userInfo?['speedlimit'],
            },
            {
              'title': 'تاریخ انقضا',
              'value': userInfo?['expire_at'],
            },
            {
              'title': 'گروه',
              'value': userInfo?['group'],
            },
            {
              'title': 'بسته',
              'value': userInfo?['package'],
            },
            {
              'title': 'مصرف شده',
              'value': userInfo?['used'],
            },
            {
              'title': 'باقی مانده',
              'value': userInfo?['remaining'],
            },
            {
              'title': 'کل',
              'value': userInfo?['total'],
            },
            {
              'title': 'لینک فرعی',
              'value': userInfo?['sublink'],
            },
          ];
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 17, 24, 40),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Image.asset(
                'assets/images/arch.png',
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.builder(
                    itemCount: userInformation.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          width: double.infinity,
                          height: 50,
                          child: Text(
                            '${userInformation[index]['title']} :  ${userInformation[index]['value']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'vazir',
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Text(
            'اطلاعات کاربر یافت نشد',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'vazir',
              fontSize: 16,
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
