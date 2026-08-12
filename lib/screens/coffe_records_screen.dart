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