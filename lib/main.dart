import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notepad/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: SUPABASE_URL, anonKey: SUPABASE_ANON_KEY);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Notepad',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final note_stream = Supabase.instance.client
      .from('notes')
      .stream(primaryKey: ['id']);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notepad'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
        stream: note_stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (BuildContext context, int index) {
              final note = notes[index];
              return ListTile(
                title: Text(notes[index]['body']),

                onLongPress: () async {
                  await Supabase.instance.client
                      .from("notes")
                      .delete()
                      .eq('id', note['id']);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('add a note'),
                contentPadding: EdgeInsets.symmetric(horizontal: 50),
                children: [
                  TextFormField(
                    scrollPadding: EdgeInsets.all(10),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onFieldSubmitted: (value) async {
                      await Supabase.instance.client.from('notes').insert({
                        'body': value,
                      });
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Container(child: Text("ADD NOTES")),
      ),
    );
  }
}
