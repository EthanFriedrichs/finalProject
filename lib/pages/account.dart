import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//view yourself
//Navigator.push(context, MaterialPageRoute(builder: (context) => Page6()));

//views someone else
//Navigator.push(context, MaterialPageRoute(builder: (context) => Page6(userId: "userID")));

class Page6 extends StatefulWidget {
  final String? userId; // If null, view current user
  Page6({this.userId});

  @override
  State<Page6> createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  late TextEditingController _nameController;
  late TextEditingController _statusController;
  late TextEditingController _imageController;

  bool _isLoading = true;
  bool _isCurrentUser = true;
  String? _profileImageURL;
  String? _status;
  String? _lastActive;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _statusController = TextEditingController();
    _imageController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    String uid = widget.userId ?? currentUser?.uid ?? '';

    if (uid != currentUser?.uid) {
      _isCurrentUser = false;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();

    if (data != null) {
      setState(() {
        _nameController.text = data['firstname'] ?? '';
        _statusController.text = data['lastname'] ?? '';
        _imageController.text = data['profile'] ?? '';
        _profileImageURL = data['profile'];
        _isLoading = false;
        _status = data['status'];
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return '${dt.month}/${dt.day}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }

  Future<void> _saveProfile() async {
    if (!_isCurrentUser) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'firstname': _nameController.text,
        'lastname': _statusController.text,
        'profile': _imageController.text,
      });

      setState(() {
        _profileImageURL = _imageController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isCurrentUser ? 'My Profile' : 'User Profile')),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: _profileImageURL != null && _profileImageURL!.isNotEmpty
                      ? NetworkImage(_profileImageURL!)
                      : null,
                  child: _profileImageURL == null || _profileImageURL!.isEmpty
                      ? const Icon(Icons.person, size: 80)
                      : null,
                ),
                const SizedBox(height: 12),
                if (_status != null)
                  Text(
                    _status!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    enabled: _isCurrentUser,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _statusController,
                    enabled: _isCurrentUser,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _imageController,
                    enabled: _isCurrentUser,
                    decoration: const InputDecoration(
                      labelText: 'Profile Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_isCurrentUser)
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text('Save', style: TextStyle(fontSize: 20)),
                          ),
                          onPressed: _saveProfile,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}