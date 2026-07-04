import 'package:airdrop/services/admin.dart';
import 'package:flutter/material.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  @override
  void initState() {
    super.initState();
    AdminServices.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AdminServices.adminUserList]),
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Column(children: AdminServices.adminUserList.value),
              SizedBox(height: 66),
            ],
          ),
        );
      },
    );
  }
}
