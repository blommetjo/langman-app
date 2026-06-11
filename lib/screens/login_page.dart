import 'package:flutter/material.dart';

import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool rememberMe = true;
  bool obscurePassword = true;
  bool isLoading = false;

  // Tijdelijk hardcoded
  bool databaseOnline = true;

  Future<void> login() async {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vul gebruikersnaam en wachtwoord in',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await ApiService.login(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;

   if (result["status"] == "success") {
  Navigator.pushNamed(
    context,
    "/dashboard",
    arguments: {
      "naam": result["naam"],
      "rol": result["rol"],
    },
  );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["message"] ??
                "Inloggen mislukt",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA),

      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 450,

            child: Card(
              elevation: 8,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(30),

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    Image.asset(
                      'assets/langman_logo.png',
                      height: 120,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      'Langman App',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Voorraad & Bedrijfsbeheer',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    Container(
                      padding:
                          const EdgeInsets.all(
                              12),
                      decoration:
                          BoxDecoration(
                        color:
                            databaseOnline
                                ? Colors
                                    .green
                                    .shade50
                                : Colors
                                    .red
                                    .shade50,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    12),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            databaseOnline
                                ? Icons
                                    .cloud_done
                                : Icons
                                    .cloud_off,
                            color:
                                databaseOnline
                                    ? Colors
                                        .green
                                    : Colors
                                        .red,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            databaseOnline
                                ? "Database verbonden"
                                : "Database offline",
                            style:
                                TextStyle(
                              color:
                                  databaseOnline
                                      ? Colors
                                          .green
                                      : Colors
                                          .red,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    TextField(
                      controller:
                          usernameController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Gebruikersnaam',
                        prefixIcon:
                            Icon(Icons.person),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    TextField(
                      controller:
                          passwordController,
                      obscureText:
                          obscurePassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Wachtwoord',
                        prefixIcon:
                            const Icon(
                                Icons.lock),
                        border:
                            const OutlineInputBorder(),
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons
                                    .visibility
                                : Icons
                                    .visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    CheckboxListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      title: const Text(
                        "Wachtwoord onthouden",
                      ),
                      value: rememberMe,
                      onChanged:
                          (value) {
                        setState(() {
                          rememberMe =
                              value ??
                                  false;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 50,

                      child:
                          ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : login,

                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'INLOGGEN',
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Face ID volgt later',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.face,
                      ),
                      label: const Text(
                        'Face ID',
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Divider(),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'Versie 1.0.0',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}