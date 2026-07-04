import 'package:airdrop/services/admin.dart';
import 'package:airdrop/widget/admin_rain_comp.dart';
import 'package:airdrop/widget/rain.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:flutter/material.dart';

ValueNotifier<List<Widget>> rainWidgets = ValueNotifier([]);

class AdminRains extends StatefulWidget {
  const AdminRains({super.key});

  @override
  State<AdminRains> createState() => _AdminRainsState();
}

class _AdminRainsState extends State<AdminRains> {
  ValueNotifier<List<Widget>> adminRain = ValueNotifier([]);
  Future<void> getRains() async {
    var list = await ByBugDatabase.getAll("rain");
    for (var element in list) {
      adminRain.value.add(
        AdminRainComponent(
          value: element["value"],
          tag: element["tag"],
          award: element["value"]["award"],
          name: element["value"]["title"],
          uid: element["value"]["uid"] ?? "",
          about: element["value"]["about"],
          status: element["value"]["status"],
        ),
      );
    }
    adminRain.notifyListeners();
  }

  @override
  void initState() {
    super.initState();
    getRains();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([adminRain]),
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Column(children: adminRain.value),
              SizedBox(height: 66),
            ],
          ),
        );
      },
    );
  }
}
