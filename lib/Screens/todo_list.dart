import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/Screens/add_page.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  bool isloading = true;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isloading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final id = item['_id'];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        //open edit
                      } else if (value == 'delete') {
                        //delete and remove the item
                        deleteById(id);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Text('Edit'),
                          value: 'edit',
                        ),
                        PopupMenuItem(
                          child: Text('Delete'),
                          value: 'delete',
                        )
                      ];
                    },
                  ),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add,size: 35,),onPressed: navigateToAddPage,
      ),
    );
  }

  //navigate to another page
  void navigateToAddPage() {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(),
    );
    Navigator.push(context, route);
  }

  Future <void> deleteById(String id) async{
    //delete the item 
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);

    final response = await http.delete(uri);
    if(response.statusCode ==200){

    //remove the item
    final filtered =items.where((element) => element['_id'] !=id).toList();
      setState(() {
        items = filtered;
      });
    }
    else{
      //show error
    }
  }

  //api get all
  Future<void> fetchTodo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    //display data
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });

      setState(() {
        isloading = false;
      });
    }
  }
}
