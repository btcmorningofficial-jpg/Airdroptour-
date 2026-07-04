import 'package:airdrop/services/admin.dart';
import 'package:airdrop/services/profile.dart';
import 'package:airdrop/theme/color.dart';
import 'package:airdrop/widget/bottom.dart';
import 'package:airdrop/widget/sizer.dart';
import 'package:airdrop/widget/text.dart';
import 'package:airdrop/widget/textfield.dart';
import 'package:flutter/material.dart';

class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizerResponsive(
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            BottomPage(
              page: 1,
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  MyProfileData.data,
                  AdminServices.criptoExplorerList,
                  AdminServices.criptoExplorerListFiltered,
                ]),
                builder: (context, child) {
                  return SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: defaultColor,
                                        borderRadius: BorderRadius.circular(
                                          1020,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    h1("Cryptocurrency"),
                                    Spacer(),

                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                              textfield(
                                text: "Search",
                                textController: AdminServices.searchController,
                                onChanged: (p0) {
                                  AdminServices().filterExplorerList(
                                    AdminServices.searchController.text,
                                  );
                                },
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: AdminServices
                                        .criptoExplorerListFiltered
                                        .value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
