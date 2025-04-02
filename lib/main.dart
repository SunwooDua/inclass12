import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widget binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(InventoryApp()); // Run your app after initialization
}

class InventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InventoryHomePage(title: 'Inventory Home Page'),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  InventoryHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  // delete button
  void deleteItem(String itemId) {
    _firestore.collection('inventory').doc(itemId).delete();
  }

  void itemAdd() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("add new item"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Number of Item'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // button
                String name = nameController.text.trim();
                int quantity =
                    int.tryParse(quantityController.text.trim()) ?? 0;
                _firestore.collection('inventory').add({
                  'name': name,
                  'quantity': quantity,
                });
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void itemUpdate(String itemId) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("update item"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Number of Item'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // button
                String name = nameController.text.trim();
                int quantity =
                    int.tryParse(quantityController.text.trim()) ?? 0;
                _firestore.collection('inventory').doc(itemId).update({
                  'name': name,
                  'quantity': quantity,
                });
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UI to display Firestore data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.blue),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('inventory').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final items = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index].data() as Map<String, dynamic>;
                String itemId = items[index].id; // used for deletion
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: ListTile(
                      leading: ElevatedButton(
                        onPressed: () {
                          itemUpdate(itemId);
                        },
                        child: Text('update'),
                      ),
                      title: Text(item['name'] ?? 'Unknown Item'),
                      subtitle: Text(item['quantity'].toString() ?? '0'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          deleteItem(itemId);
                        },
                        child: Text('delete'),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          itemAdd();
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }
}
