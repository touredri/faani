import 'package:flutter/material.dart';
import 'modifier.dart';

class MesureListTile extends StatelessWidget {
  final String name;
  final String value;

  const MesureListTile({super.key, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ModifyMesure(
                      name: name,
                      value: value,
                    )));
      },
      child: Column(
        children: [
          ListTile(
            title: Text(name, style: const TextStyle(fontSize: 18)),
            trailing: SizedBox(
              width: 110,
              child: Row(
                children: [
                  Text('$value cm', style: const TextStyle(fontSize: 18)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 0.3,
            color: Colors.orange[800],
          ),
        ],
      ),
    );
  }
}