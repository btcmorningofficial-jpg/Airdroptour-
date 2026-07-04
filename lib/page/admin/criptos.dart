import 'package:airdrop/services/admin.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:flutter/material.dart';

class CriptoAdmin extends StatefulWidget {
  const CriptoAdmin({super.key});

  @override
  State<CriptoAdmin> createState() => _CriptoAdminState();
}

class _CriptoAdminState extends State<CriptoAdmin> {
  @override
  void initState() {
    super.initState();
    AdminServices.getCryptos(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AdminServices.criptoList]),
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  AdminServices.addCripto(context);
                },
                child: Opacity(
                  opacity: 0.5,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: EdgeInsets.all(10),
                    width: widthSizer(context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: navColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [bold("Add New Crypto Asset")],
                    ),
                  ),
                ),
              ),

              Column(children: AdminServices.criptoList.value),
              SizedBox(height: 66),
            ],
          ),
        );
      },
    );
  }
}
