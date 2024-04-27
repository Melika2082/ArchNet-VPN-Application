import 'package:archnet/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

// ignore: camel_case_types
class User_ServerList extends StatefulWidget {
  const User_ServerList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _User_ServerListState createState() => _User_ServerListState();
}

// ignore: camel_case_types
class _User_ServerListState extends State<User_ServerList> {
  bool isLoading = true;
  List servers = [];

  Future<void> setindex() async {
    var selectedServerBox = await Hive.openBox('selectedServerBox');
    var indexKey = selectedServerBox.get('index_key');

    if (indexKey != null) {
      selectedItem = int.parse(indexKey);
    } else {}
  }

  Future<void> getServers(String token) async {
    final res = await http.post(
      Uri.parse('https://hub.archnets.com/api/v2/client/servers'),
      headers: <String, String>{
        'XMPus-API-Token': '15dde8524a8b998932564e11b3bd5fe5',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'token': token,
      }),
    );

    if (res.statusCode == 200) {
      final serverData = jsonDecode(res.body)['servers'];
      setState(() {
        servers = serverData;
        isLoading = false;
      });
    } else {
      throw Exception('سرورها بارگیری نشد');
    }
  }

  @override
  void initState() {
    super.initState();
    setindex();
    getUserInfo().then((userInfo) {
      if (!userInfo.containsKey('error')) {
        getServers(userInfo['token']);
      }
    });
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      var box = await Hive.openBox('userBox');
      String email = box.get('email') ?? '';
      String password = box.get('password') ?? '';
      if (email.isNotEmpty && password.isNotEmpty) {
        final res = await http.post(
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
          return {'token': token};
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : servers.isEmpty
                          ? const Center(
                              child: Text(
                                'شما سروری خریداری نکرده اید',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'vazir',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : _getListServer(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ListView _getListServer() {
    return ListView.builder(
      itemCount: servers.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          child: InkWell(
            onTap: () async {
              var selectedServerBox = await Hive.openBox('selectedServerBox');
              await selectedServerBox.put('index_key', index.toString());

              setState(() {
                selectedItem = index;
                selectedServerType = "custom";
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: double.infinity,
              height: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DnsIconRowWidget(index),
                      Text(
                        '${servers[index]['remark']} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ': ${servers[index]['port'].toString()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Text(
                      servers[index]['address'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  SizedBox DnsIconRowWidget(int index) {
    return SizedBox(
      width: 40,
      height: 1,
      child: Icon(
        Icons.check_box,
        color: selectedItem == index ? kBgColor : Colors.black45,
        shadows: <Shadow>[
          selectedItem == index
              ? const Shadow(
                  offset: Offset(0.0, 0.0),
                  blurRadius: 50.0,
                  color: Color.fromARGB(255, 55, 46, 138),
                )
              : const Shadow(
                  offset: Offset(0.0, 0.0),
                  blurRadius: 50.0,
                  color: Colors.white,
                ),
        ],
      ),
    );
  }
}
