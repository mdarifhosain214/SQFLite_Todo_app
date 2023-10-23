import 'package:flutter/material.dart';
import 'package:sqflite_todo_app/sqflite_helper.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _journals = [];

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    _journals = data;
    setState(() {});
  }

  String latitudeValue = '';
  String langtitudeValue = '';
  bool isLoaded = false;
  void getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Give the permition");
      LocationPermission permissionLocation =
          await Geolocator.requestPermission();
    } else {
      isLoaded = true;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      langtitudeValue = position.longitude.toString();
      latitudeValue = position.latitude.toString();
      setState(() {});
    }
  }

  @override
  void initState() {
    _refreshJournals();
    print("....number of items ${_journals.length}");
    super.initState();
  }

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleEditingController.text, latitudeValue,
        _descriptionEditingController.text);
    getLocation();
    _refreshJournals();
    print("....number of items ${_journals.length}");
  }

  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleEditingController.text, latitudeValue,
        _descriptionEditingController.text);
    getLocation();
    _refreshJournals();
  }

  void _delete(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleEditingController.text = existingJournal['title'];
      _descriptionEditingController.text = existingJournal['description'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _titleEditingController,
                      decoration: const InputDecoration(
                          hintText: "Title", border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      maxLines: 5,
                      controller: _descriptionEditingController,
                      decoration: const InputDecoration(
                          hintText: "Description",
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (id == null) {
                            await _addItem();
                            getLocation();
                          }
                          if (id != null) {
                            await updateItem(id);
                            getLocation();
                          }
                          _titleEditingController.text = '';
                          _descriptionEditingController.text = '';
                          Navigator.pop(context);
                        },
                        child: Text(id == null ? "Create new" : "Update"))
                  ]),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: const Text("Sqlflite")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(null);
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                    child: Text(_journals[index]['id'].toString())),
                title: Text(_journals[index]['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_journals[index]['description']),
                    Text(_journals[index]['createAt']),
                    Row(
                      children: [
                        Icon(Icons.location_on),
                        Text(_journals[index]['location']),
                      ],
                    )
                  ],
                ),
                trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              _showForm(_journals[index]['id']);
                            },
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () {
                              _delete(_journals[index]['id']);
                            },
                            icon: const Icon(Icons.delete))
                      ],
                    )),
              ),
            );
          }),
    );
  }
}
