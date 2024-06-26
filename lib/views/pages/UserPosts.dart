import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cvault/models/Post.dart';
import 'package:cvault/services/post_service.dart';
import 'package:cvault/widgets/Confirmation.dart';
import 'package:cvault/widgets/EditPostForm.dart';
import 'package:intl/intl.dart';

class UserPostPage extends StatefulWidget {
  @override
  _UserPostPageState createState() => _UserPostPageState();
}

class _UserPostPageState extends State<UserPostPage> {
  final _postCollection = FirebaseFirestore.instance.collection('posts');
  final _userId = FirebaseAuth.instance.currentUser?.uid;
  final _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _postCollection.where('userId', isEqualTo: _userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.512,
            ),
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              final post = Post.fromFirestore(snapshot.data!.docs[index]);
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${DateFormat('dd/MM/yyyy').format(post.timestamp)}'),
                    if (post.imageUrl != null)
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(post.imageUrl!),
                      ),
                    Expanded(
                      child: ListTile(
                        title: Text(post.title),
                        subtitle: Text(post.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(Icons.favorite, color: Colors.red),
                            Text('${post.likes}'),
                          ],
                        ),
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: EditPostForm(post: post),
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ConfirmationDialog(
                                  title: 'Confirmar eliminación',
                                  content:
                                      '¿Estás seguro de que quieres eliminar este post?',
                                  onConfirm: () {
                                    _postService.deletePost(post.id);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
