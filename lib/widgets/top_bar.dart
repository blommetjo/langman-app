import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String naam;
  final String rol;

  const TopBar({
    super.key,
    required this.naam,
    required this.rol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      color: Colors.white,
      child: Row(
        children: [

          Text(
            "Welkom terug, $naam",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [

              Text(
                naam,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                rol,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(width: 15),

          CircleAvatar(
            backgroundColor:
                Colors.blue.shade700,
            child: Text(
              naam.isNotEmpty
                  ? naam[0].toUpperCase()
                  : "U",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}