import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddToDoPage extends StatefulWidget {
  final Map? todo;
  const AddToDoPage({super.key,this.todo});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if(widget.todo !=null){
      isEdit = true; 
      final title = todo?['title'];
      final description = todo?['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit?'Edit Todo' : "Add Todo"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              hintText: 'Description',
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: isEdit? updateData : submitData,
           child:  Text(isEdit? 'Update':'Submit'))
        ],
      ),
    );
  }

  Future <void> updateData()async{
    final todo = widget.todo;
    if(todo == null){
      print("cant update");
      return;
    }
    final id = todo['_id'];
 final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
       "description": description, 
       "is_completed": false
       };
       //submit data to the server
    //update

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url); 
    final response = await http.put(
      uri, 
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json'
      }
      );
 if(response.statusCode == 200){

      showSuccessMessage("  Update Success");
    }
    else{
      showErrorMessage("Update Failed");
    }
  }

  Future <void> submitData() async{
    //get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
       "description": description, 
       "is_completed": false
       };

    //submit data to the server
    //http post 

    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url); 
    final response = await http.post(
      uri, 
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json'
      }
      );

    //show success and fail message based on status
    if(response.statusCode == 201){
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage("Creation Success");
    }
    else{
      showErrorMessage("Creation Failed");
    }
  }
  
  //visual message 
  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message,style: TextStyle(color: Colors.white),),
    backgroundColor: Colors.blue,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } 
  void showErrorMessage(String message){
    final snackBar = SnackBar(content: Text(message,style: TextStyle(color: Colors.white),),
    backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
