import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:motion_web/services/addexercisesservices.dart';
import 'package:motion_web/services/addsubexercisesservies.dart';
import 'package:motion_web/utils/customcolor.dart';
import 'package:motion_web/widgets/ElevatedButtonWidget.dart';
import 'package:motion_web/widgets/text_widget.dart';

class AddSubexercisesScreen extends StatefulWidget {
  const AddSubexercisesScreen({super.key});

  @override
  State<AddSubexercisesScreen> createState() => _AddSubexercisesScreenState();
}

class _AddSubexercisesScreenState extends State<AddSubexercisesScreen> {
  final AddExercisesServices addExercisesServices = Get.put(AddExercisesServices());
  final AddSubExercisesServies addSubExercisesServies = Get.put(AddSubExercisesServies());
  List<Map<String, dynamic>> exercises = [];
  String? selectedExercise;
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    exercises = await addExercisesServices.getAllExercises();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Container(
                  width: screenWidth * 0.30,
                  child: DropdownButtonFormField<String>(
                    value: selectedExercise,
                    hint: Text('Select Exercise'),
                    items: exercises.map((exercise) {
                      return DropdownMenuItem<String>(
                        value: exercise['docId'],
                        child: Text(exercise['exercise'] ?? 'No Exercise Name'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedExercise = value;
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      fillColor: Colors.white24,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: btncolor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: btncolor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: btncolor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: btncolor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: screenWidth * 0.30,
                  child: TextField(
                    controller: reasonController,
                    maxLines: 3,
                    cursorColor: Colors.blue,
                    style: TextStyle(fontFamily: "PTSerif", color: Colors.black),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      hintText: 'Reason',
                      hintStyle: TextStyle(
                        fontFamily: "PTSerif",
                        color: Colors.black.withOpacity(0.4),
                      ),
                      fillColor: Colors.white24,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: btncolor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: btncolor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: btncolor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: btncolor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GetBuilder<AddSubExercisesServies>(
                    builder: (logic) {
                      return logic.loading == true ? Center(
                        child: SpinKitFadingCircle(
                          size: 50,
                          color: Colors.blue,
                        ),
                      ) : ElevatedButtonWidget(
                        buttonHeight: 50,
                        buttonborderRadius: 15,
                        buttonBackgroundColor: btncolor,
                        buttonWidth: screenWidth * 0.30,
                        onPressed: () async {
                          if (selectedExercise != null && reasonController.text.isNotEmpty) {
                            await addSubExercisesServies.addReasonToExercise(selectedExercise!, reasonController.text);
                            setState(() {
                              reasonController.clear();
                            });
                          } else {
                            Get.snackbar(
                              "Error",
                              "Please select an exercise and enter a reason",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: AppText.heading("Save", fontsize: 18, color: Colors.white),
                      );
                    }),
              ],
            ),
            SizedBox(width: 30),
            VerticalDivider(color: btncolor, width: 8),
            SizedBox(width: 30),
            if (selectedExercise != null)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: addSubExercisesServies.getReasonsForExercise(selectedExercise!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitFadingCircle(
                        size: 50,
                        color: Colors.blue,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching reasons'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No reasons found'));
                  } else {
                    List<Map<String, dynamic>> reasons = snapshot.data!;
                    return Container(
                      width: screenWidth * 0.40,
                      child: ReorderableListView.builder(
                        itemCount: reasons.length,
                        itemBuilder: (context, index) {
                          final reason = reasons[index]['reason'] ?? 'No Reason';
                          final reasonId = reasons[index]['id'];
                          return Container(
                            key: ValueKey(reasonId),
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: btncolor, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText.heading(reason, fontsize: 16),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await addSubExercisesServies.deleteReasonFromExercise(selectedExercise!, reasonId);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onReorder: (int oldIndex, int newIndex) async {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final movedReason = reasons.removeAt(oldIndex);
                          reasons.insert(newIndex, movedReason);

                          for (int i = 0; i < reasons.length; i++) {
                            await addSubExercisesServies.updateReasonIndex(selectedExercise!, reasons[i]['id'], i);
                          }

                          setState(() {});
                        },
                      ),
                    );
                  }
                },
              )

          ],
        ),
      ),
    );
  }
}