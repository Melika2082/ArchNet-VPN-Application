import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:archnet/vpnService/vpn_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archnet/snackBar/snackbar.dart';
import '../vpnService/vpn_status_provider.dart';
import 'package:archnet/services/utils.dart';
import 'package:archnet/data/user_info.dart';
import 'package:archnet/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/user_server_list.dart';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

const kBgColor = Color.fromARGB(255, 15, 40, 71);
const kColorBg = Color(0xffE6E7F0);

String? selectedServerType = "custom";
int? selectedItem;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // ignore: non_constant_identifier_names

  String fileName = "conf.json";

  Timer? _timer;

  Duration _duration = const Duration();

  bool _isConnected = false;
  bool fileExists = false;

  late List fileContent;
  late File jsonFile;
  late Directory dir;

  List myList = [];

  startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        const addSeconds = 1;
        setState(() {
          final seconds = _duration.inSeconds + addSeconds;
          _duration = Duration(seconds: seconds);
        });
      },
    );
  }

  stopTimer() {
    setState(() {
      _timer?.cancel();
      _duration = const Duration();
    });
  }

  // خواندن سرور های کپی شده از محل حافظه ی شخصی
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    getApplicationDocumentsDirectory().then(
      (Directory directory) {
        dir = directory;
        jsonFile = File("${dir.path}/$fileName");
        fileExists = jsonFile.existsSync();
        if (fileExists) {
          setState(() =>
              myList = List.from(jsonDecode(jsonFile.readAsStringSync())));
        }
      },
    );
    setindex();
  }

  void createFile(List content, Directory dir, String fileName) {
    File file = File("${dir.path}/$fileName");
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
  }

  void writeToFile(List value) {
    if (fileExists) {
      List jsonFileContent = value;
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    } else {
      createFile(value, dir, fileName);
    }
    // ignore: avoid_print
    setState(() => print(json.decode(jsonFile.readAsStringSync())));
  }

  Future<void> setindex() async {
    var indexKey = await storage.read(key: 'index_key');

    if (indexKey != null) {
      selectedItem = int.parse(indexKey);
    } else {}
  }

  Future<String> deviceHWID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    // print('Running on ${androidInfo.hardware}');
    return androidInfo.display;
  }

  String hashString(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return buildDirectionalityWidget(size);
  }

  /*

  FlutterV2ray? flutterV2ray;
  V2RayURL? v2rayURL;

  String status = '';
  String ping = '';

  initV2ray() async {
    flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        setState(() {
          this.status = status.state;
        });
      },
    );

    await flutterV2ray!.initializeV2Ray();
    v2rayURL = FlutterV2ray.parseFromURL(
        'https://hub.archnets.com/api/v2/client/servers');
  }

  getPing() async {
    int p = await flutterV2ray!.getConnectedServerDelay();

    setState(() {
      ping = '$p ms';
    });
  }

  connect() async {
    if (await flutterV2ray!.requestPermission()) {
      flutterV2ray!.startV2Ray(
        remark: v2rayURL!.remark,
        config: v2rayURL!.getFullConfiguration(),
        blockedApps: null,
        bypassSubnets: null,
        proxyOnly: false,
      );
    }
  }

  disconnect() async {
    setState(() {
      status = '';
      ping = '';
    });

    await flutterV2ray!.stopV2Ray();
  }

  */

  // بخش منوی پاینن سمت راست صفحه اصلی
  Directionality buildDirectionalityWidget(Size size) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          type: ExpandableFabType.side,
          openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.menu),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.white,
            backgroundColor: kBgColor,
            shape: const CircleBorder(),
            angle: 2 * 2,
          ),
          closeButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.add),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.white,
            backgroundColor: kBgColor,
            shape: const CircleBorder(),
            angle: 2 * 2,
          ),
          children: [
            // دریافت سرور از بخش لیست کپی ها
            FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: kBgColor,
              heroTag: null,
              child: const Icon(Icons.add),
              onPressed: () {
                Clipboard.getData(Clipboard.kTextPlain).then((value) async {
                  RegExp exp =
                      RegExp('vless://(.*?)@(.*?):(.*?)\\?(.*?)#(.*?)\$');
                  RegExpMatch? match = exp.firstMatch(value!.text.toString());

                  if (match != null) {
                    // print(value.text.toString());
                    // ignore: non_constant_identifier_names
                    var ConfigMap = {
                      'remark': match[5],
                      'link': value.text,
                      'port': match[3],
                      'domain': match[2],
                    };
                    // print(myList.toString());

                    setState(() {
                      myList.add(ConfigMap);
                      writeToFile(myList);
                      // print(myList.toList());
                    });
                  } else {
                    showSncackBar(
                      titleText: 'خطای پردازش',
                      captionText: 'متن کپی شده قابل پردازش نمیباشد',
                      textColor: Colors.white,
                      bgColor: const Color.fromARGB(255, 17, 24, 40),
                      icon: const Icon(
                        Icons.error,
                        color: Colors.white,
                      ),
                    );
                  }
                });
              },
            ),
            // بخش خروج از حساب کاربری
            FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              heroTag: null,
              child: const Icon(Icons.exit_to_app),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'خروج از حساب کاربری',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                        'آیا میخواهید از حساب کاربری خارج شوید؟',
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            Hive.box('userBox').delete('token');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const LoginPage();
                                },
                              ),
                            );
                          },
                          child: const Text(
                            'بله',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'خیر',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        key: _scaffoldKey,
        backgroundColor: kBgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: buildHomeScreenBody(size),
          ),
        ),
      ),
    );
  }

/*
  Column testVPN() {
    return Column(
      children: [
        TextButton(onPressed: () {connect();}, child: const Text('connect')),
        TextButton(onPressed: () {disconnect();}, child: const Text('disconnect')),
        TextButton(onPressed: () {getPing();}, child: const Text('ping')),
      ],
    );
  }
*/
  Column buildHomeScreenBody(Size size) {
    return Column(
      children: [
        // نصف کردن صفحه با رنگ پس زمینه های مختلف
        SizedBox(
          height: size.height * 0.45,
          child: buildMainColumn(size),
        ),
        Container(
          height: Platform.isIOS ? size.height * 0.51 : size.height * 0.565,
          decoration: const BoxDecoration(
            // رنگ پس زمینه نصف پایینی صفحه
            color: Color.fromARGB(255, 17, 24, 40),
          ),
          // لیستی از سرور های vpn
          child: ListView(
            children: [
              buildCustomConfigsList(size),
            ],
          ),
        ),
      ],
    );
  }

  // بخش دریافت لیستی از سرورهای vpn
  Column buildCustomConfigsList(Size size) {
    return Column(
      children: [
        Center(
          child: InkWell(
            onTap: () => {},
            child: const Padding(
              padding: EdgeInsets.all(8.0),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.ltr,
            children: [
              const Text(
                'اطلاعات کاربر',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'vazir',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              userInfoCard(),
              purchasedServerListCard(),
              const SizedBox(width: 20, height: 10),
              const Text(
                'لیست سرورهای کپی شده',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'vazir',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 20, height: 10),
              ...listGenerate(),
            ],
          ),
        ),
        const SizedBox(width: 20, height: 30),
        const SizedBox(height: 5),
        const SizedBox(height: 20),
      ],
    );
  }

  Padding purchasedServerListCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const User_ServerList();
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: 66,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'لیست سرور های خریداری شده',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'vazir',
                    fontSize: 16,
                  ),
                ),
                Text('برای مشاهده لیست سرورها کلیک کنید'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding userInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const UserInfo();
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: 66,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مشخصات کاربر',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'vazir',
                    fontSize: 16,
                  ),
                ),
                Text('برای مشاهده اطلاعات کاربری کلیک کنید'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> listGenerate() {
    return List.generate(
      myList.length,
      (index) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(bottom: 1, left: 3, right: 3),
              child: Material(
                color: const Color.fromARGB(255, 17, 24, 40),
                borderRadius: BorderRadius.circular(7),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Card(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async {
                        await storage.write(
                          key: 'index_key',
                          value: index.toString(),
                        );
                        setState(() {
                          selectedItem = index;
                          selectedServerType = "custom";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        height: 60,
                        child: Row(
                          children: [
                            buildConfigItem(index),
                            const Spacer(),
                            buildDeleteButton(index),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Container buildPingIndicatorWithIndex(int index) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: kColorBg.withOpacity(0.7),
        shape: BoxShape.rectangle,
      ),
      child: InkWell(
        onTap: () async {
          if (selectedItem == index) {
          } else {
            setState(
              () {
                if (selectedItem! > myList.length) {
                  selectedItem = selectedItem! - 1;
                }
                myList.removeAt(index);
                writeToFile(myList);
              },
            );
          }
        },
      ),
    );
  }

  Container buildDeleteButton(int index) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: kColorBg.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        child: const Icon(
          Icons.delete,
          size: 22,
          color: kBgColor,
        ),
        onTap: () async {
          await VpnManager().disconnect();
          setState(() {
            stopTimer();
            _isConnected = false;
            myList.removeAt(index);
            writeToFile(myList);
          });
        },
      ),
    );
  }

  Row buildConfigItem(int index) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          height: 30,
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
                      color: Color.fromARGB(255, 255, 255, 255),
                    )
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.65,
                      ),
                      child: Text(
                        myList[index]['remark'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${myList[index]['domain']} : ${myList[index]['port']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Column buildEmptyColumn() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        SizedBox(
          width: 5,
        ),
      ],
    );
  }

//*********************************************************** */
  Column buildMainColumn(Size size) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/arch.png',
                height: MediaQuery.of(context).size.height * 0.06,
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Material(
            color: kBgColor,
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.02,
                ),
                Center(
                  child: Consumer<VpnStatusProvider>(
                    builder: (context, vpnStatusProvider, child) {
                      return InkWell(
                        onTap: (vpnStatusProvider.vpnStatus !=
                                VpnStatus.connecting)
                            ? () async {
                                if (vpnStatusProvider.vpnStatus ==
                                    VpnStatus.connect) {
                                  await VpnManager().disconnect();
                                  stopTimer();
                                  setState(() => _isConnected = false);
                                } else {
                                  var indexKey =
                                      await storage.read(key: 'index_key');
                                  // print(indexKey.toString());
                                  RegExp exp = RegExp(
                                      'vless://(.*?)@(.*?):(.*?)\\?(.*?)#(.*?)\$');

                                  if (selectedServerType == "custom") {
                                    try {
                                      RegExpMatch? match = exp.firstMatch(
                                          myList[int.parse(indexKey!)]['link']!
                                              .toString());
                                      if (match == null) {
                                        throw Exception(
                                          'برای شروع به کار VPN باید سرور داشته باشید.',
                                        );
                                      } else {
                                        await VpnManager().connect(
                                            "vless://${match[1]!}@127.0.0.1:3035?${match[4]!}#${match[5]!}",
                                            match[5]!,
                                            match[3]!,
                                            match[2]!);
                                        // print("custom");
                                        startTimer();
                                        setState(() {
                                          _isConnected = true;
                                        });
                                      }
                                    } catch (e) {
                                      showDialog(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const AlertDialog(
                                            title: Text(
                                              'برای شروع به کار باید سرور داشته باشید',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  }
                                  _isConnected == false ? startTimer() : null;
                                  setState(() => _isConnected = true);
                                }
                              }
                            : null,
                        borderRadius: BorderRadius.circular(size.height),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 166, 139, 139)
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: size.height * 0.12,
                              height: size.height * 0.12,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.power_settings_new,
                                      size: size.height * 0.035,
                                      color: kBgColor,
                                    ),
                                    Text(
                                      _isConnected == true
                                          ? 'قطع اتصال'
                                          : 'اتصال',
                                      style: TextStyle(
                                        fontSize: size.height * 0.013,
                                        fontWeight: FontWeight.w500,
                                        color: kBgColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: _isConnected ? 90 : size.height * 0.14,
                      height: size.height * 0.030,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _isConnected == true ? 'متصل' : 'اتصال برقرار نیست',
                        style: TextStyle(
                          fontSize: size.height * 0.015,
                          color: kBgColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.012,
                    ),
                    _countDownWidget(size),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _countDownWidget(Size size) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_duration.inMinutes.remainder(60));
    final seconds = twoDigits(_duration.inSeconds.remainder(60));
    final hours = twoDigits(_duration.inHours.remainder(60));

    return Text(
      '$hours :  $minutes : $seconds ',
      style: TextStyle(color: Colors.white, fontSize: size.height * 0.03),
    );
  }
}
