import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:summer_iub_app/models/coffee_records_model.dart';
import 'package:summer_iub_app/state_management/coffee_state_management.dart';
import 'package:summer_iub_app/widgets/app_backgroud_design_widget.dart';

class CoffeRecordsScreen extends StatefulWidget {
  const CoffeRecordsScreen({super.key});

  @override
  State<CoffeRecordsScreen> createState() => _CoffeRecordsScreenState();
}

class _CoffeRecordsScreenState extends State<CoffeRecordsScreen> {
  Future<void> _showEditDialog(
    BuildContext context,
    CoffeeStateManagement csm,
    CoffeeRecordsModel coffeeRecord,
  ) async {
    final titleController =
        TextEditingController(text: coffeeRecord.title);

    final amountController =
        TextEditingController(text: coffeeRecord.amount.toString());

    final descriptionController =
        TextEditingController(text: coffeeRecord.des);

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Coffee Record"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter title";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter amount";
                      }

                      if (double.tryParse(value) == null) {
                        return "Please enter a valid amount";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description",
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter description";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final updatedRecord = CoffeeRecordsModel(
                  id: coffeeRecord.id,
                  title: titleController.text.trim(),
                  des: descriptionController.text.trim(),
                  amount:
                      double.tryParse(amountController.text.trim()) ?? 0.0,
                  date: coffeeRecord.date,
                );

                await csm.updateCoffeeRecord(updatedRecord);

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    CoffeeStateManagement csm,
    CoffeeRecordsModel coffeeRecord,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Coffee Record"),
          content: Text(
            "Are you sure you want to delete "
            "\"${coffeeRecord.title}\"?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await csm.deleteCoffeeRecord(coffeeRecord.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Coffee Records",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CoffeeStateManagement>(
        builder: (context, csm, _) {
          return AppBackgroudDesignWidget(
            child: StreamBuilder<List<CoffeeRecordsModel>>(
              stream: csm.getCoffeeRecords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                    ),
                  );
                }

                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return const Center(
                    child: Text(
                      "No coffee records found.",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final CoffeeRecordsModel coffeeRecord = records[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.coffee),
                        title: Text(coffeeRecord.title),
                        subtitle: Text(
                          "${coffeeRecord.des}\n"
                          "Amount: ${coffeeRecord.amount}\n"
                          "ID: ${coffeeRecord.id}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: "Edit",
                              onPressed: () {
                                _showEditDialog(
                                  context,
                                  csm,
                                  coffeeRecord,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: "Delete",
                              onPressed: () {
                                _showDeleteDialog(
                                  context,
                                  csm,
                                  coffeeRecord,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<CoffeeStateManagement>(
        builder: (context, csm, _) {
          return FloatingActionButton(
            onPressed: () async {
              final newRecord = CoffeeRecordsModel(
                id: DateTime.now().microsecondsSinceEpoch,
                title: "Coffee Record",
                des: "Details about Coffee Record",
                amount: 10.0,
                date: DateTime.now(),
              );

              await csm.addCoffeeRecord(newRecord);
            },
            child: const Icon(Icons.local_cafe),
          );
        },
      ),
    );
  }
}