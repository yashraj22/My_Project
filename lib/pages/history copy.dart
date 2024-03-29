import 'package:flutter/material.dart';
import 'package:app/database.dart';
import '../main.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "History",
//       home: HistoryScreen(),
//     );
//   }
// }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: Data.length,
          itemBuilder: (_, index) {
            return ListTile(
              enableFeedback: true,
              title: Text(Data[index]),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // delete logic here
                  setState(() {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete Item"),
                            content: const Text(
                                "Are you sure you want to delete this item?"),
                            actions: [
                              TextButton(
                                child: const Text("CANCEL"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text("DELETE"),
                                onPressed: () {
                                  // Delete item
                                  setState(() {
                                    Data.removeWhere(
                                        (element) => element == Data[index]);
                                    notesDataBox.deleteAt(index);
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  });
                },
              ),
            );
          }),
    );
  }
}
