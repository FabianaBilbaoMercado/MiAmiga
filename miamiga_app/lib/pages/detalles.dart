import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/index/indexes.dart';


class ReadCases extends StatefulWidget {
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denuncianteData;

  const ReadCases({
    super.key,
    required this.user,
    required this.incidentData,
    required this.denuncianteData,
  });

  @override
  State<ReadCases> createState() => _ReadCasesState();
}

class _ReadCasesState extends State<ReadCases> {

  Future<List<DenuncianteData>> _fetchCases() async {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return [];
  }

  final QuerySnapshot supervisorCasesSnapshot = 
    await FirebaseFirestore.instance
    .collection('cases')
    .where('estado', isEqualTo: 'pendiente')
    .where('supervisor', isEqualTo: widget.user!.uid)
    // .orderBy('denunciante.fullname')  // Order by fullName
    .get(const GetOptions(source: Source.server));

  return _mapSnapshotToDenuncianteData(supervisorCasesSnapshot);
}

List<DenuncianteData> _mapSnapshotToDenuncianteData(QuerySnapshot snapshot) {
  return snapshot.docs
    .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final denuncianteData = data['denunciante'] as Map<String, dynamic>?;

      if (denuncianteData != null) {
        return DenuncianteData(
          userId: denuncianteData['userId'] ?? '',
          fullName: denuncianteData['fullname'] ?? '',
          ci: denuncianteData['ci'] ?? 0,
          phone: denuncianteData['phone'] ?? 0,
          lat: denuncianteData['lat'] ?? 0.0,
          long: denuncianteData['long'] ?? 0.0,
          documentId: doc.id,
          estado: data['estado'] ?? '',
        );
      } else {
        return DenuncianteData(
          userId: '',
          fullName: '',
          ci: 0,
          phone: 0,
          lat: 0.0,
          long: 0.0,
          documentId: doc.id,
          estado: data['estado'] ?? '',
        );
      }
    })
    .toList();
  }

    @override
    void initState() {
      super.initState();
      _fetchCases();
    }

      

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 15),
          const Header(header: 'Casos'),
          Expanded(
            child: FutureBuilder(
              future: _fetchCases(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(255, 87, 110, 1),
                    )
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay casos'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      final caseData = snapshot.data?[index];
                      return GestureDetector(
                        onTap: () {
                          if (widget.user != null) {
                            final userId = caseData.userId;
                            final documentId = caseData.documentId;
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                _fetchCases();
                                return DetalleDenuncia(
                                  userIdDenuncia: userId!,
                                  documentIdDenuncia: documentId,
                                  user: widget.user,
                                  incidentData: widget.incidentData,
                                  denuncianteData: widget.denuncianteData,
                                  future: Future(() => null),
                                );
                              })
                            );
                          }
                        },
                        child: Card(
                          color: const Color.fromRGBO(248, 181, 149, 1),
                          margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  caseData!.fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'CI: ${caseData.ci}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Estado: ${caseData.estado}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}