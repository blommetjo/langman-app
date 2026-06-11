import 'package:flutter/material.dart';

import '../widgets/app_sidebar.dart';
import '../widgets/top_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;

    final String naam =
        args?['naam'] ?? 'Gebruiker';

    final String rol =
        args?['rol'] ?? 'Medewerker';

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),

      body: Row(
        children: [

          const AppSidebar(),

          Expanded(
            child: Column(
              children: [

                TopBar(
                  naam: naam,
                  rol: rol,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(25),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Productie Dashboard",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        Row(
                          children: [

                            _statCard(
                              "Open Werkbonnen",
                              "18",
                              Icons.assignment,
                              Colors.blue,
                            ),

                            const SizedBox(
                              width: 20,
                            ),

                            _statCard(
                              "In Productie",
                              "6",
                              Icons.factory,
                              Colors.green,
                            ),

                            const SizedBox(
                              width: 20,
                            ),

                            _statCard(
                              "Machines",
                              "12",
                              Icons.precision_manufacturing,
                              Colors.orange,
                            ),

                            const SizedBox(
                              width: 20,
                            ),

                            _statCard(
                              "Instructies",
                              "2",
                              Icons.menu_book,
                              Colors.purple,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        const Text(
                          "Modules",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [

                            _moduleCard(
                              "Werkbonnen",
                              Icons.assignment,
                            ),

                            _moduleCard(
                              "Machines",
                              Icons.precision_manufacturing,
                            ),

                            _moduleCard(
                              "Instellingen",
                              Icons.settings_applications,
                            ),

                            _moduleCard(
                              "Handleidingen",
                              Icons.menu_book,
                            ),

                            _moduleCard(
                              "Producten",
                              Icons.inventory_2,
                            ),

                            _moduleCard(
                              "Gebruikers",
                              Icons.people,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Expanded(
                              child: Card(
                                elevation: 3,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                    20,
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      const Text(
                                        "Open Werkbonnen",
                                        style:
                                            TextStyle(
                                          fontSize:
                                              22,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),

                                      _werkbon(
                                        "WB-2026-0145",
                                        "Kozijn type 68mm",
                                      ),

                                      _werkbon(
                                        "WB-2026-0146",
                                        "Voordeur model A",
                                      ),

                                      _werkbon(
                                        "WB-2026-0147",
                                        "Raamkozijn",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 20,
                            ),

                            Expanded(
                              child: Card(
                                elevation: 3,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                    20,
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      const Text(
                                        "Machine Instellingen",
                                        style:
                                            TextStyle(
                                          fontSize:
                                              22,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),

                                      _machine(
                                        "SCM Accord",
                                        "Kozijn 68mm",
                                      ),

                                      _machine(
                                        "CNC 01",
                                        "Voordeur Model A",
                                      ),

                                      _machine(
                                        "Weinig Powermat",
                                        "90mm Profiel",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Icon(
              icon,
              color: color,
            ),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(title),
          ],
        ),
      ),
    );
  }

  static Widget _moduleCard(
    String title,
    IconData icon,
  ) {
    return Container(
      width: 180,
      height: 140,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            size: 45,
            color: Colors.blue,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _werkbon(
    String nummer,
    String omschrijving,
  ) {
    return ListTile(
      leading:
          const Icon(Icons.assignment),
      title: Text(nummer),
      subtitle: Text(omschrijving),
    );
  }

  static Widget _machine(
    String machine,
    String instelling,
  ) {
    return ListTile(
      leading: const Icon(
        Icons.precision_manufacturing,
      ),
      title: Text(machine),
      subtitle: Text(instelling),
    );
  }
}