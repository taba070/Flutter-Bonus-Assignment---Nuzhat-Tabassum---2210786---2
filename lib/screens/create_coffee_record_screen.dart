import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:summer_iub_app/models/coffee_records_model.dart';
import 'package:summer_iub_app/state_management/coffee_state_management.dart';
import 'package:summer_iub_app/utility/vlaidators.dart';
import 'package:summer_iub_app/widgets/app_backgroud_design_widget.dart';
import 'package:summer_iub_app/widgets/core_input_widget.dart';
import 'coffe_records_screen.dart';

class CreateCoffeeRecordScreen extends StatelessWidget {
  const CreateCoffeeRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
        TextEditingController();

    final TextEditingController amountController =
        TextEditingController();

    final TextEditingController descriptionController =
        TextEditingController();

    final formKey = GlobalKey<FormState>();

    final csm = Provider.of<CoffeeStateManagement>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Coffee Record",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: AppBackgroudDesignWidget(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CoreInputWidget(
                  controller: titleController,
                  labelText: "Title",
                  validator: CustomValidators.validateTitle,
                ),

                const SizedBox(height: 20),

                CoreInputWidget(
                  controller: amountController,
                  labelText: "Amount",
                  keyboardType: TextInputType.number,
                  validator: CustomValidators.validateAmount,
                ),

                const SizedBox(height: 20),

                CoreInputWidget(
                  controller: descriptionController,
                  labelText: "Description",
                  keyboardType: TextInputType.multiline,
                  maxLine: 5,
                  validator: CustomValidators.validateDescreption,
                ),

                const Spacer(),

                ElevatedButton.icon(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final CoffeeRecordsModel newRecord =
                        CoffeeRecordsModel(
                      id: DateTime.now().microsecondsSinceEpoch,
                      title: titleController.text,
                      des: descriptionController.text,
                      amount:
                          double.tryParse(amountController.text) ?? 0.0,
                      date: DateTime.now(),
                    );

                    await csm.addCoffeeRecord(newRecord);

                    if (!context.mounted) return;

                    titleController.clear();
                    amountController.clear();
                    descriptionController.clear();

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            const CoffeRecordsScreen(),
                      ),
                    );
                  },
                  label: const Text(
                    "Save Coffee Record",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: const Icon(
                    Icons.save,
                    size: 30,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}