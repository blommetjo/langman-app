import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WerkbonDetailPage extends StatefulWidget {
  final int werkbonId;

  const WerkbonDetailPage({
    super.key,
    required this.werkbonId,
  });

  @override
  State<WerkbonDetailPage> createState() =>
      _WerkbonDetailPageState();
}

class _WerkbonDetailPageState
    extends State<WerkbonDetailPage> {
  Set<int> geselecteerdeRegels = {};
  bool loading = true;

  Map werkbon = {};
  List regels = [];

  final String apiUrl =
      "http://10.26.80.10/langman_api";

  @override
  void initState() {
    super.initState();
    laadWerkbon();
  }

  int totaalMeter() {
    double totaal = 0;

    for (var regel in regels) {
      totaal += double.tryParse(
            regel["aantal"].toString(),
          ) ??
          0;
    }

    return totaal.round();
  }

  String bepaalType(
    String artikelnummer,
  ) {
    if (artikelnummer.startsWith("V.")) {
      return "Vlechten";
    }

    if (artikelnummer.startsWith("S.")) {
      return "Geslagen";
    }

    return "-";
  }

 Future<void> laadWerkbon() async {
  final response = await http.get(
    Uri.parse(
      "$apiUrl/get_werkbon.php?id=${widget.werkbonId}",
    ),
  );

  final data =
      jsonDecode(response.body);

  setState(() {
    werkbon =
        data["werkbon"];

    regels =
        data["regels"];

    loading = false;
  });
}

Future<void> bulkUitsluiten(
  bool uitsluiten,
) async {

 for (final regelId
    in geselecteerdeRegels) {

  await http.post(
    Uri.parse(
      "$apiUrl/update_werkbon_regel.php",
    ),
    body: {
      "id": regelId.toString(),
      "voorraad_gebruikt": "0",
      "extra_voorraad": "0",
      "opmerkingen": "",
      "uitgesloten":
          uitsluiten ? "1" : "0",
    },
  );
}

geselecteerdeRegels.clear();

await laadWerkbon();

if (!mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(
  SnackBar(
    content: Text(
      uitsluiten
          ? "Regels uitgesloten"
          : "Regels teruggezet",
    ),
  ),
);

}

  Future<void> wijzigRegel(
  Map regel,
) async {
  final voorraadController =
      TextEditingController(
    text: regel["voorraad_gebruikt"]
            ?.toString() ??
        "0",
  );

  final extraController =
      TextEditingController(
    text: regel["extra_voorraad"]
            ?.toString() ??
        "0",
  );

  final opmerkingController =
      TextEditingController(
    text: regel["opmerkingen"]
            ?.toString() ??
        "",
  );

  bool uitgesloten =
      regel["uitgesloten"]
              .toString() ==
          "1";

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder:
            (context, setDialogState) {
          return AlertDialog(
            title: Text(
              regel["artikelnummer"],
            ),
            content:
                SingleChildScrollView(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  TextField(
                    controller:
                        voorraadController,
                    keyboardType:
                        TextInputType
                            .number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Voorraad gebruiken",
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                        extraController,
                    keyboardType:
                        TextInputType
                            .number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Extra voorraad",
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextField(
                    controller:
                        opmerkingController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Werkbon opmerking",
                    ),
                  ),

                  CheckboxListTile(
                    value:
                        uitgesloten,
                    title: const Text(
                      "Niet produceren",
                    ),
                    onChanged:
                        (value) {
                      setDialogState(() {
                        uitgesloten =
                            value ??
                                false;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  "Annuleren",
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await http.post(
                    Uri.parse(
                      "$apiUrl/update_werkbon_regel.php",
                    ),
                    body: {
                      "id": regel["id"]
                          .toString(),
                      "voorraad_gebruikt":
                          voorraadController
                              .text,
                      "extra_voorraad":
                          extraController
                              .text,
                      "opmerkingen":
                          opmerkingController
                              .text,
                      "uitgesloten":
                          uitgesloten
                              ? "1"
                              : "0",
                    },
                  );

                  if (!mounted) {
                    return;
                  }

                  Navigator.pop(
                    context,
                  );

                  laadWerkbon();
                },
                child: const Text(
                  "Opslaan",
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          werkbon["werkbonnummer"] ??
              "Werkbon",
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    werkbon["klantnaam"] ??
                        "",
                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Contact: ${werkbon["contactpersoon"] ?? "-"}",
                  ),

                  Text(
                    "Leverdatum: ${werkbon["leverdatum"] ?? "-"}",
                  ),

                  Text(
                    "Status: ${werkbon["status"] ?? "-"}",
                  ),

                  const Divider(),

                  Text(
                    "Aantal regels: ${regels.length}",
                  ),

                  Text(
                    "Totaal meter: ${totaalMeter()}",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

if (geselecteerdeRegels.isNotEmpty)
  Card(
    color: Colors.blue.shade50,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            "${geselecteerdeRegels.length} regel(s) geselecteerd",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      bulkUitsluiten(true),
                  icon: const Icon(
                    Icons.block,
                  ),
                  label: const Text(
                    "Niet produceren",
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      bulkUitsluiten(false),
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label: const Text(
                    "Terugzetten",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),

  

          const Text(
            "Productieregels",
            style: TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

         ...regels.map((regel) {
  return Card(
    margin: const EdgeInsets.only(
      bottom: 12,
    ),
    child: Padding(
      padding: const EdgeInsets.all(
        16,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          CheckboxListTile(
            value:
                geselecteerdeRegels.contains(
              int.parse(
                regel["id"]
                    .toString(),
              ),
            ),
            title: const Text(
              "Selecteren",
            ),
            controlAffinity:
                ListTileControlAffinity
                    .leading,
            contentPadding:
                EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                final id =
                    int.parse(
                  regel["id"]
                      .toString(),
                );

                if (value == true) {
                  geselecteerdeRegels
                      .add(id);
                } else {
                  geselecteerdeRegels
                      .remove(id);
                }
              });
            },
          ),

          Text(
            regel["artikelnummer"] ??
                "",
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            regel["omschrijving"] ??
                "",
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "${regel["aantal"]} ${regel["eenheid"]}",
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            "Type: ${bepaalType(regel["artikelnummer"] ?? "")}",
          ),

          Text(
            "Touwtype: ${regel["touw_type"] ?? "-"}",
          ),

          Text(
            "Constructie: ${regel["constructie"] ?? "-"}",
          ),

          Text(
            "Kleurcode: ${regel["kleur_code"] ?? "-"}",
          ),

          Text(
            "Diameter: ${regel["diameter"] ?? "-"} mm",
          ),

          const SizedBox(
            height: 12,
          ),

Text(
  "Voorraad gebruikt: "
  "${regel["voorraad_gebruikt"] ?? "0"} "
  "${regel["eenheid"]}",
),

Text(
  "Extra voorraad: "
  "${regel["extra_voorraad"] ?? "0"} "
  "${regel["eenheid"]}",
),

Builder(
  builder: (_) {
    final aantal =
        double.tryParse(
              regel["aantal"]
                  .toString(),
            ) ??
            0;

    final voorraad =
        double.tryParse(
              regel["voorraad_gebruikt"]
                  .toString(),
            ) ??
            0;

    final extra =
        double.tryParse(
              regel["extra_voorraad"]
                  .toString(),
            ) ??
            0;

    final teProduceren =
        aantal -
        voorraad +
        extra;

    return Text(
      "Te produceren: "
      "${teProduceren.toStringAsFixed(0)} "
      "${regel["eenheid"]}",
      style:
          const TextStyle(
        fontWeight:
            FontWeight.bold,
      ),
    );
  },
),

if (regel["uitgesloten"]
        .toString() ==
    "1")
  Container(
    margin:
        const EdgeInsets.only(
      top: 10,
    ),
    padding:
        const EdgeInsets.all(
      10,
    ),
    decoration:
        BoxDecoration(
      color:
          Colors.red.shade100,
      borderRadius:
          BorderRadius.circular(
        8,
      ),
    ),
    child: const Text(
      "UITGESLOTEN VAN PRODUCTIE",
      style: TextStyle(
        fontWeight:
            FontWeight.bold,
      ),
    ),
  ),

const SizedBox(
  height: 12,
),

ElevatedButton.icon(
  onPressed: () =>
      wijzigRegel(
    regel,
  ),
  icon: const Icon(
    Icons.edit,
  ),
  label: const Text(
    "Wijzigen",
  ),
),

                    if ((regel["opmerkingen"] ?? "")
                        .toString()
                        .isNotEmpty)
                      Container(
                        width:
                            double.infinity,
                        margin:
                            const EdgeInsets
                                .only(
                          top: 12,
                        ),
                        padding:
                            const EdgeInsets
                                .all(
                          12,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .amber
                              .shade100,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            8,
                          ),
                        ),
                        child: Text(
                          regel[
                              "opmerkingen"],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}