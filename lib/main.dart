import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LangmanApp());
}

/* ================= APP ================= */

class LangmanApp extends StatelessWidget {
  const LangmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Langman',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2A5298),
      ),
      home: const LoginPage(),
    );
  }
}

/* ================= LOGIN ================= */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool rememberMe = true;

  String status = "checking";
  final String baseUrl = "http://10.26.80.10/langman_api";

  @override
  void initState() {
    super.initState();
    checkStatus();
    loadSavedUser();
  }

  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("username");
    if (saved != null) {
      setState(() => userCtrl.text = saved);
    }
  }

  Future<void> checkStatus() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/status.php"));
      setState(() => status = res.statusCode == 200 ? "online" : "offline");
    } catch (_) {
      setState(() => status = "offline");
    }
  }

  Future<void> login() async {
    if (userCtrl.text.isEmpty || passCtrl.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {
          "username": userCtrl.text,
          "password": passCtrl.text,
        },
      );

      final data = jsonDecode(res.body);

      if (data["status"] == "success") {
        final prefs = await SharedPreferences.getInstance();
        if (rememberMe) {
          prefs.setString("username", userCtrl.text);
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Dashboard(name: data["naam"]),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login mislukt")),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server niet bereikbaar")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(blurRadius: 30, color: Colors.black26),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/langman_logo.png", height: 90),
                  const SizedBox(height: 15),
                  const Text(
                    "Langman Login",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: "Gebruikersnaam",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: passCtrl,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Wachtwoord",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (v) =>
                            setState(() => rememberMe = v ?? true),
                      ),
                      const Text("Onthoud mij"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("Inloggen"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: status == "online"
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status == "online"
                          ? "🟢 Server online"
                          : "🔴 Server offline",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= DASHBOARD ================= */

class Dashboard extends StatelessWidget {
  final String name;

  const Dashboard({super.key, required this.name});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welkom $name"),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == "logout") {
                logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "logout",
                child: Text("Uitloggen"),
              ),
            ],
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE4E8F0)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _DashCard(
                icon: Icons.inventory_2,
                title: "Producten",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductPage(),
                    ),
                  );
                },
              ),
              const _DashCard(icon: Icons.people, title: "Klanten"),
              const _DashCard(icon: Icons.shopping_cart, title: "Orders"),
              const _DashCard(icon: Icons.settings, title: "Instellingen"),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= DASH CARD ================= */

class _DashCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _DashCard({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 15, color: Colors.black12),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF2A5298)),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}

/* ================= PRODUCTS ================= */

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List products = [];
  List filtered = [];
  bool loading = true;

  final baseUrl = "http://10.26.80.10/langman_api";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/products.php"));
      final data = jsonDecode(res.body);

      if (data["status"] == "success") {
        setState(() {
          products = data["data"];
          filtered = products;
          loading = false;
        });
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  void search(String value) {
    final words = value.toLowerCase().trim().split(" ");

    setState(() {
      filtered = products.where((p) {
        final allText =
            "${p["zoeknaam"]} ${p["artikelnummer"]} ${p["materiaal"]} ${p["soort"]} ${p["diameter"]}"
                .toLowerCase();

        return words.every((w) => allText.contains(w));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Producten")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    onChanged: search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Zoek producten...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final p = filtered[i];

                      return ListTile(
                        title: Text(p["zoeknaam"] ?? ""),
                        subtitle: Text(
                          "Artikel: ${p["artikelnummer"]} | Ø ${p["diameter"]}",
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetail(product: p),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/* ================= PRODUCT DETAIL ================= */

class ProductDetail extends StatelessWidget {
  final Map product;

  const ProductDetail({super.key, required this.product});

  Widget info(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(blurRadius: 12, color: Colors.black12),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2A5298)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value.isEmpty ? "-" : value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      product["zoeknaam"] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product["zoeknaam"] ?? "",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          Text("Artikel: ${product["artikelnummer"] ?? "-"}",
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    info("Materiaal", product["materiaal"] ?? "", Icons.category),
                    info("Soort", product["soort"] ?? "", Icons.widgets),
                    info("Constructie", product["constructie"] ?? "", Icons.build),
                    info("Diameter", product["diameter"] ?? "", Icons.circle),
                    info("Klant", product["klant"] ?? "", Icons.person),
                    info("Opmerking", product["opmerking"] ?? "", Icons.notes),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}